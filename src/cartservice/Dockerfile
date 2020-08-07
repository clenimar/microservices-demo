# Build on dotnet native image
FROM microsoft/dotnet:2.1-sdk-alpine as builder

WORKDIR /app

COPY . .

RUN dotnet restore && \
    dotnet build --no-incremental
# NOTE: release currently not working - crashes on SCONE
#    dotnet publish -c release -r linux-musl-x64 -o /cartservice


# cartservice
#FROM sconecuratedimages/mono
FROM sconecuratedimages/experimental:mono-5-alpine

RUN GRPC_HEALTH_PROBE_VERSION=v0.3.5 && \
    wget -qO/bin/grpc_health_probe https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/${GRPC_HEALTH_PROBE_VERSION}/grpc_health_probe-linux-amd64 && \
    chmod +x /bin/grpc_health_probe

## Dependencies for runtime
## busybox-extras => telnet
#RUN apk add --no-cache \
#    busybox-extras \
#    libc6-compat \
#    libunwind \
#    libuuid \
#    libgcc \
#    libstdc++ \
#    libintl \
#    icu

WORKDIR /app

COPY --from=builder /root/.nuget/ /root/.nuget
COPY --from=builder /app/ /app/

# Fix case mismatch in CommandLine assembly
WORKDIR /root/.nuget/packages/commandlineparser/2.2.1/lib/netstandard1.5
RUN mv CommandLine.dll commandline.dll

# Manually export the package locations...
ENV MONO_PATH /root/.nuget/packages/commandlineparser/2.2.1/lib/netstandard1.5:/root/.nuget/packages/stackexchange.redis/2.0.601/lib/netstandard2.0:/root/.nuget/packages/google.protobuf/3.6.1/lib/netstandard1.0:/root/.nuget/packages/grpc.healthcheck/1.12.0/lib/netstandard1.5

ENV SCONE_VERSION=1 SCONE_LOG=7

# Go to output dir...
WORKDIR /app/bin/Debug/netcoreapp2.1

ENTRYPOINT ["mono", "cartservice.dll", "start"]
