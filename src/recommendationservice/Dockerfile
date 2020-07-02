# google-cloud-debug dependency has no released
# package for alpine, so we need to built it from
# source and copy to the final image.
FROM alpine:3.7 as cdbg

ENV PYTHON=python2
# from requirements.txt
ENV CDBG_VERSION 2.9

RUN apk update
RUN apk add bash git curl gcc g++ make cmake ${PYTHON}-dev "py-setuptools<45"

RUN git clone -b $CDBG_VERSION  https://github.com/GoogleCloudPlatform/cloud-debug-python
RUN PYTHON=$PYTHON bash cloud-debug-python/src/build.sh

FROM sconecuratedimages/apps:pypy2-alpine

ENV SCONE_ALLOW_DLOPEN 2
ENV SCONE_MODE auto
ENV SCONE_LOG 7
ENV SCONE_HEAP=128M

RUN apk --update add --no-cache \
      wget \
      g++ \
      libexecinfo-dev \
      libstdc++

# show python logs as they occur
ENV PYTHONUNBUFFERED=0

# download the grpc health probe
RUN GRPC_HEALTH_PROBE_VERSION=v0.3.5 && \
    wget -qO/bin/grpc_health_probe https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/${GRPC_HEALTH_PROBE_VERSION}/grpc_health_probe-linux-amd64 && \
    chmod +x /bin/grpc_health_probe

# get packages
WORKDIR /recommendationservice
COPY requirements.txt requirements.txt
# newer setuptools versions (>=47.0.0) do not
# support Python 2 anymore.
# pin the version that still works.
RUN pip install "setuptools<=45.0.0"
RUN pip install --upgrade pip
RUN pip install wheel
RUN pip install -r requirements.txt

COPY --from=cdbg /cloud-debug-python/src/dist/*.egg .
RUN python -m easy_install *.egg
RUN rm *.egg

# add files into working directory
COPY . .

# set listen port
ENV PORT "8080"
EXPOSE 8080

# google-cloud-profiler dependency fails to build.
# disable profiling for now...
ENV DISABLE_PROFILER 1

ENTRYPOINT ["python", "/recommendationservice/recommendation_server.py"]
