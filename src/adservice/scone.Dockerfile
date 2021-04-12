ARG SCONE_VERSION=5.3.0

FROM openjdk:15-alpine as builder

WORKDIR /app

RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
       && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.30-r0/glibc-2.30-r0.apk \
       && apk add glibc-2.30-r0.apk

RUN echo "@testing http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories

RUN apk add protobuf@testing

COPY ["build.gradle", "gradlew", "./"]
COPY gradle gradle
RUN chmod +x gradlew
RUN ./gradlew --stacktrace downloadRepos

COPY . .
RUN chmod +x gradlew
RUN ./gradlew installDist

FROM registry.scontain.com:5050/sconecuratedimages/apps:openjdk-17-alpine-scone${SCONE_VERSION}

# Download Stackdriver Profiler Java agent
#RUN apt-get -y update && apt-get install -qqy \
#    wget \
#    && rm -rf /var/lib/apt/lists/*

RUN apk add --update --no-cache wget

RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
       && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.30-r0/glibc-2.30-r0.apk \
       && apk add glibc-2.30-r0.apk

RUN echo "@testing http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories

RUN apk add protobuf@testing

#RUN mkdir -p /opt/cprof && \
#    wget -q -O- https://storage.googleapis.com/cloud-profiler/java/latest/profiler_java_agent.tar.gz \
#    | tar xzv -C /opt/cprof && \
#    rm -rf profiler_java_agent.tar.gz

RUN GRPC_HEALTH_PROBE_VERSION=v0.3.6 && \
    wget -qO/bin/grpc_health_probe https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/${GRPC_HEALTH_PROBE_VERSION}/grpc_health_probe-linux-amd64 && \
    chmod +x /bin/grpc_health_probe

WORKDIR /app
COPY --from=builder /app .

EXPOSE 9555
ENTRYPOINT ["/app/build/install/hipstershop/bin/AdService"]
