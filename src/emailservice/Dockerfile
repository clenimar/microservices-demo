#FROM python:3.7-slim as base
#FROM registry.scontain.com:5050/sconecuratedimages/apps:python-3.7-alpine as base
FROM registry.scontain.com:5050/sconecuratedimages/apps:python-3.7.3-alpine3.10-scone5.0.0 as base

#RUN apt-get -qq update \
#    && apt-get install -y --no-install-recommends \
#        g++ \
#    && rm -rf /var/lib/apt/lists/*

RUN apk add --update --no-cache g++ libexecinfo-dev wget

# get packages
COPY requirements.txt .
RUN pip3 install -r requirements.txt

# Enable unbuffered logging
ENV PYTHONUNBUFFERED=1
# Enable Profiler
ENV ENABLE_PROFILER=1

ENV SCONE_MODE auto
ENV SCONE_HEAP 256M
ENV SCONE_LOG 7
ENV SCONE_ALLOW_DLOPEN 2

#RUN apt-get -qq update \
#    && apt-get install -y --no-install-recommends \
#        wget

#RUN apk add --update --no-cache wget

# Download the grpc health probe
RUN GRPC_HEALTH_PROBE_VERSION=v0.3.6 && \
    wget -qO/bin/grpc_health_probe https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/${GRPC_HEALTH_PROBE_VERSION}/grpc_health_probe-linux-amd64 && \
    chmod +x /bin/grpc_health_probe

WORKDIR /email_server

# Grab packages from builder
#COPY --from=builder /usr/local/lib/python3.7/ /usr/local/lib/python3.7/

# Add the application
COPY . .

EXPOSE 8080
ENTRYPOINT [ "python", "email_server.py" ]
