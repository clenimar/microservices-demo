FROM golang:1.15-alpine AS builder

FROM registry.scontain.com:5050/sconecuratedimages/crosscompilers:alpine3.7-scone5.0.0

COPY --from=builder /usr/local/go/ /usr/local/go/

RUN apk add --no-cache --update ca-certificates git

ENV GOPATH /go
ENV GOROOT /usr/local/go
RUN mkdir -p "$GOPATH/bin" "$GOPATH/src" && \
    chmod -R 777 "$GOPATH"                  # FIXME: change permission

ENV PATH $PATH:$GOPATH/bin:$GOROOT/bin

WORKDIR /src

# restore dependencies
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -compiler gccgo -buildmode=exe -gccgoflags -g -o /shippingservice .

RUN GRPC_HEALTH_PROBE_VERSION=v0.2.0 && \
    wget -qO/bin/grpc_health_probe https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/${GRPC_HEALTH_PROBE_VERSION}/grpc_health_probe-linux-amd64 && \
    chmod +x /bin/grpc_health_probe

ENV APP_PORT=50051
EXPOSE 50051
ENV SCONE_HEAP 2G
ENTRYPOINT ["/shippingservice"]

