FROM alpine:3.7 as cdbg

ENV PYTHON=python2

RUN apk update
RUN apk add bash git curl gcc g++ make cmake ${PYTHON}-dev py-setuptools

RUN git clone https://github.com/GoogleCloudPlatform/cloud-debug-python
RUN PYTHON=$PYTHON bash cloud-debug-python/src/build.sh

FROM sconecuratedimages/apps:pypy-2.7.15-alpine3.7

ENV SCONE_ALLOW_DLOPEN 2
ENV SCONE_MODE auto
ENV SCONE_LOG 7
ENV SCONE_HEAP=128M

RUN apk --update add --no-cache \
      wget \
      g++ \
      libexecinfo-dev \
      libstdc++ \
      py-setuptools

# show python logs as they occur
ENV PYTHONUNBUFFERED=0

# download the grpc health probe
RUN GRPC_HEALTH_PROBE_VERSION=v0.3.5 && \
    wget -qO/bin/grpc_health_probe https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/${GRPC_HEALTH_PROBE_VERSION}/grpc_health_probe-linux-amd64 && \
    chmod +x /bin/grpc_health_probe

# get packages
WORKDIR /recommendationservice
COPY requirements.txt requirements.txt
RUN pip install --upgrade pip
RUN pip install wheel
RUN pip install -r requirements.txt

# install google-cloud-debugger from "cdbg".
ENV PYTHON=python2

COPY --from=cdbg /cloud-debug-python/src/dist/*.egg .
RUN $PYTHON -m easy_install *.egg
RUN rm *.egg

# add files into working directory
COPY . .

# set listen port
ENV PORT "8080"
EXPOSE 8080

ENTRYPOINT ["python", "/recommendationservice/recommendation_server.py"]
