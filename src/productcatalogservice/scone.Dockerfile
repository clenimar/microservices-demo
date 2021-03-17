ARG SCONE_VERSION=5.2.1

# Use multi-stage build to get a newer Go version.
# Final image is based on Alpine 3.7, which only has Go 1.9.4.
FROM golang:1.15-alpine AS go

FROM registry.scontain.com:5050/sconecuratedimages/crosscompilers:alpine3.7-scone${SCONE_VERSION} as binary-fs

RUN apk add --no-cache --update ca-certificates git

COPY --from=go /usr/local/go/ /usr/local/go/

ENV GOPATH /go

ENV GOROOT /usr/local/go

ENV PATH $PATH:$GOPATH/bin:$GOROOT/bin

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && \
    chmod -R 777 "$GOPATH" # FIXME: permission

ENV PROJECT github.com/GoogleCloudPlatform/microservices-demo/src/productcatalogservice

WORKDIR $GOPATH/src/$PROJECT

# restore dependencies
COPY go.mod go.sum ./

RUN go mod download

COPY . .

RUN mkdir -p /productcatalogservice

RUN go build -compiler gccgo -buildmode=exe -gccgoflags -g -o /productcatalogservice/server .

WORKDIR /productcatalogservice

COPY products.json ./

RUN SCONE_MODE=auto scone binaryfs / /binary-fs.c -v \
    --include /productcatalogservice/products.json \
    && scone gcc /binary-fs.c -O0 -shared -o /libbinary-fs.so \
    && apk add --no-cache patchelf \
    && patchelf --add-needed /libbinary-fs.so /productcatalogservice/server

FROM registry.scontain.com:5050/sconecuratedimages/crosscompilers:alpine3.7-scone${SCONE_VERSION}

WORKDIR /productcatalogservice

COPY --from=binary-fs /productcatalogservice/server ./

COPY --from=binary-fs /libbinary-fs.so /

ENV LD_LIBRARY_PATH /

RUN GRPC_HEALTH_PROBE_VERSION=v0.2.0 && \
    wget -qO/bin/grpc_health_probe https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/${GRPC_HEALTH_PROBE_VERSION}/grpc_health_probe-linux-amd64 && \
    chmod +x /bin/grpc_health_probe

EXPOSE 3550

ENV SCONE_HEAP 1G

ENTRYPOINT ["/productcatalogservice/server"]
