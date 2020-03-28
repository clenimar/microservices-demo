FROM sconecuratedimages/apps:pypy-2.7.15-alpine3.7

ENV SCONE_ALLOW_DLOPEN 2
ENV SCONE_MODE auto
ENV SCONE_LOG 7

RUN apk --update add --no-cache \
      wget \
      g++ \
      libexecinfo-dev

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

# add files into working directory
COPY . .

# set listen port
ENV PORT "8080"
EXPOSE 8080

ENTRYPOINT ["python", "/recommendationservice/recommendation_server.py"]
