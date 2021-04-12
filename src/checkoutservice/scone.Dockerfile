ARG SCONE_VERSION=5.3.0

FROM golang:1.15-alpine AS builder

FROM registry.scontain.com:5050/sconecuratedimages/crosscompilers:alpine3.7-scone${SCONE_VERSION}

COPY --from=builder /usr/local/go/ /usr/local/go/

RUN apk add --no-cache --update ca-certificates git

ENV GOPATH /go
ENV GOROOT /usr/local/go

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && \
    chmod -R 777 "$GOPATH"                  # FIXME: change permission

ENV PATH $GOPATH/bin:$GOROOT/bin:$PATH

WORKDIR /src

# restore dependencies
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN go build -compiler gccgo -buildmode=exe -gccgoflags -g -o /checkoutservice .

RUN GRPC_HEALTH_PROBE_VERSION=v0.3.6 && \
    wget -qO/bin/grpc_health_probe https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/${GRPC_HEALTH_PROBE_VERSION}/grpc_health_probe-linux-amd64 && \
    chmod +x /bin/grpc_health_probe

EXPOSE 5050
ENV SCONE_HEAP 2G
ENTRYPOINT ["/checkoutservice"]
