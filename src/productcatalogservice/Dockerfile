FROM golang:1.15-alpine AS builder

FROM sconecuratedimages/crosscompilers:alpine3.7-scone5.0.0

RUN apk add --no-cache --update ca-certificates git

COPY --from=builder /usr/local/go/ /usr/local/go/
ENV GOPATH /go
ENV GOROOT /usr/local/go
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && \
    chmod -R 777 "$GOPATH"

ENV PATH $PATH:$GOPATH/bin:$GOROOT/bin

RUN wget -qO $GOPATH/bin/dep https://github.com/golang/dep/releases/download/v0.5.0/dep-linux-amd64 && \
      chmod +x $GOPATH/bin/dep

ENV PROJECT github.com/GoogleCloudPlatform/microservices-demo/src/productcatalogservice

WORKDIR $GOPATH/src/$PROJECT

WORKDIR /src
# restore dependencies
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN mkdir -p /productcatalogservice
RUN go build -compiler gccgo -buildmode=exe -gccgoflags -g -o /productcatalogservice/server .

RUN GRPC_HEALTH_PROBE_VERSION=v0.2.0 && \
    wget -qO/bin/grpc_health_probe https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/${GRPC_HEALTH_PROBE_VERSION}/grpc_health_probe-linux-amd64 && \
    chmod +x /bin/grpc_health_probe

WORKDIR /productcatalogservice
COPY products.json .
EXPOSE 3550
ENV SCONE_HEAP 1G
ENTRYPOINT ["/productcatalogservice/server"]
