# NOTE: Instrumentation is disabled because the respective
# dependencies are not fully compatible with Alpine:
# google-cloud-profiler
# google-python-cloud-debugger

ARG SCONE_VERSION=5.3.0

FROM registry.scontain.com:5050/sconecuratedimages/apps:python-3.7.3-alpine3.10-scone${SCONE_VERSION} AS binary-fs

RUN apk --update add --no-cache \
      wget \
      g++ \
      libexecinfo-dev \
      libstdc++ \
      linux-headers

WORKDIR /recommendationservice

COPY requirements.txt requirements.txt

RUN pip3 install -r requirements.txt

COPY . .

RUN SCONE_MODE=auto scone binaryfs / /binary-fs.c -v \
        --include '/usr/lib/python3.7/*' \
        --include /recommendationservice/demo_pb2.py \
        --include /recommendationservice/demo_pb2_grpc.py \
        --include /recommendationservice/client.py \
        --include /recommendationservice/recommendation_server.py \
        --include /recommendationservice/logger.py \
        --include '/usr/lib/libstdc++.so.6*' \
        --include '/usr/lib/libgcc_s.so.1*' \
        --include '/lib/libz.so.1*' \
        --include '/usr/lib/libbz2.so.1*' \
        --include '/usr/lib/libffi.so.6*' \
        --include '/usr/lib/libexpat.so.1*' \
        --include '/lib/libssl.so.4*' \
        --include '/lib/libcrypto.so.1*' \
        --include '/lib/libssl.so.1*' \
        --include '/usr/lib/libncursesw.so.6*'

FROM registry.scontain.com:5050/sconecuratedimages/crosscompilers:alpine3.7-scone${SCONE_VERSION} AS crosscompiler

COPY --from=binary-fs /binary-fs.c /.

RUN scone gcc /binary-fs.c -O0 -shared -o /libbinary-fs.so

FROM registry.scontain.com:5050/sconecuratedimages/apps:python-3.7.3-alpine3.10-scone${SCONE_VERSION}

COPY --from=crosscompiler /libbinary-fs.so /.

RUN apk add --no-cache patchelf && \
    patchelf --add-needed libbinary-fs.so `which python3` && \
    apk del patchelf

# download the grpc health probe
RUN GRPC_HEALTH_PROBE_VERSION=v0.3.6 && \
    wget -qO/bin/grpc_health_probe https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/${GRPC_HEALTH_PROBE_VERSION}/grpc_health_probe-linux-amd64 && \
    chmod +x /bin/grpc_health_probe

# Disable instrumentation because dependencies
# are not compatible with Alpine.
# google-cloud-profiler and google-python-cloud-debugger
ENV DISABLE_PROFILER 1
ENV DISABLE_DEBUGGER 1

# show python logs as they occur
ENV PYTHONUNBUFFERED=0

ENV SCONE_ALLOW_DLOPEN 2
ENV SCONE_HEAP=512M
ENV LD_LIBRARY_PATH /

# set listen port
ENV PORT "8080"
EXPOSE 8080

ENTRYPOINT ["python", "/recommendationservice/recommendation_server.py"]
