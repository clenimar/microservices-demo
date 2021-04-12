ARG SCONE_VERSION=5.3.0

# Use multi-stage build to get a newer Go version.
# Final image is based on Alpine 3.7, which only has Go 1.9.4.
FROM golang:1.15-alpine AS go

FROM registry.scontain.com:5050/sconecuratedimages/crosscompilers:alpine3.7-scone${SCONE_VERSION} AS binary-fs

RUN apk add --no-cache --update \
        bind-tools \
        busybox-extras \
        ca-certificates \
        net-tools \
        git

COPY --from=go /usr/local/go/ /usr/local/go/

ENV GOPATH /go

ENV GOROOT /usr/local/go

ENV PATH $PATH:$GOPATH/bin:$GOROOT/bin

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && \
    chmod -R 777 "$GOPATH"                  # FIXME: change permission

ENV PROJECT github.com/GoogleCloudPlatform/microservices-demo/src/frontend

WORKDIR $GOPATH/src/$PROJECT

# restore dependencies
COPY go.mod go.sum ./

RUN go mod download

COPY . .

RUN mkdir -p /frontend

RUN go build -compiler gccgo -buildmode=exe -gccgoflags -g -o /frontend/server .

WORKDIR /frontend

COPY ./templates ./templates

COPY ./static ./static

RUN SCONE_MODE=auto scone binaryfs / /binary-fs.c -v \
    --include '/frontend/templates/*' \
    --include '/frontend/static/*' \
    && scone gcc /binary-fs.c -O0 -shared -o /libbinary-fs.so \
    && apk add --no-cache patchelf \
    && patchelf --add-needed /libbinary-fs.so /frontend/server

FROM registry.scontain.com:5050/sconecuratedimages/crosscompilers:alpine3.7-scone${SCONE_VERSION}

WORKDIR /frontend

COPY --from=binary-fs /frontend/server ./

COPY --from=binary-fs /libbinary-fs.so /

ENV LD_LIBRARY_PATH /

EXPOSE 8080

ENV SCONE_HEAP 2G

ENTRYPOINT ["/frontend/server"]
