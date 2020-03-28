FROM golang:1.10-alpine AS builder

FROM sconecuratedimages/experimental:crosscompilers-alpine3.7

COPY --from=builder /usr/local/go/ /usr/local/go/

RUN apk add --no-cache --update git ca-certificates

ENV GOPATH /go
ENV GOROOT /usr/local/go
ENV SCONE_HEAP 1G

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && \
      chmod -R 777 "$GOPATH"

ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

RUN wget -qO/go/bin/dep https://github.com/golang/dep/releases/download/v0.5.0/dep-linux-amd64 && \
      chmod +x /go/bin/dep

FROM golang:1.15-alpine AS builder
RUN apk add --no-cache ca-certificates git

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
ENTRYPOINT ["/productcatalogservice/server"]
