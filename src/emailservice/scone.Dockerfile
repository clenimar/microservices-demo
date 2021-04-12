ARG SCONE_VERSION=5.3.0

FROM registry.scontain.com:5050/sconecuratedimages/apps:python-3.7.3-alpine3.10-scone${SCONE_VERSION} AS binary-fs

RUN apk add --update --no-cache g++ libexecinfo-dev linux-headers wget

WORKDIR /emailservice

COPY . .

RUN pip3 install -r requirements.txt

RUN rm /usr/lib/python3.7/config-3.7m-x86_64-linux-gnu/libpython3.7m.a && \
    SCONE_MODE=auto scone binaryfs / /binary-fs.c -v \
        --include '/usr/lib/python3.7/*' \
        --include /emailservice/demo_pb2.py \
        --include /emailservice/demo_pb2_grpc.py \
        --include /emailservice/email_client.py \
        --include /emailservice/email_server.py \
        --include /emailservice/logger.py \
        --include /emailservice/templates/confirmation.html \
        --include '/usr/lib/libstdc++.so.6*' \
        --include '/usr/lib/libgcc_s.so.1*' \
        --include '/lib/libz.so.1*' \
        --include '/lib/libssl.so.1*' \
        --include '/lib/libcrypto.so.1*' \
        --include '/usr/lib/libbz2.so.1*' \
        --include '/usr/lib/libffi.so.6*' \
        --include '/usr/lib/libexpat.so.1*'

FROM registry.scontain.com:5050/sconecuratedimages/crosscompilers:alpine3.7-scone${SCONE_VERSION} AS crosscompiler

COPY --from=binary-fs /binary-fs.c /.

RUN scone gcc /binary-fs.c -O0 -shared -o /libbinary-fs.so

FROM registry.scontain.com:5050/sconecuratedimages/apps:python-3.7.3-alpine3.10-scone${SCONE_VERSION}

COPY --from=crosscompiler /libbinary-fs.so /.

RUN apk add --no-cache patchelf && \
    patchelf --add-needed libbinary-fs.so `which python3` && \
    apk del patchelf

# Enable unbuffered logging
ENV PYTHONUNBUFFERED=1

ENV SCONE_HEAP 256M
ENV SCONE_ALLOW_DLOPEN 2
ENV LD_LIBRARY_PATH /

# Download the grpc health probe
RUN GRPC_HEALTH_PROBE_VERSION=v0.3.5 && \
    wget -qO/bin/grpc_health_probe https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/${GRPC_HEALTH_PROBE_VERSION}/grpc_health_probe-linux-amd64 && \
    chmod +x /bin/grpc_health_probe

EXPOSE 8080

ENTRYPOINT [ "python3", "/emailservice/email_server.py" ]
