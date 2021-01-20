FROM golang:1.15-alpine AS builder

FROM registry.scontain.com:5050/sconecuratedimages/crosscompilers:alpine3.7-scone5.0.0

COPY --from=builder /usr/local/go/ /usr/local/go/

RUN apk add --no-cache --update \
        bind-tools \
        busybox-extras \
        ca-certificates \
        net-tools \
        git

ENV GOPATH /go
ENV GOROOT /usr/local/go
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && \
    chmod -R 777 "$GOPATH"                  # FIXME: change permission

ENV PATH $PATH:$GOPATH/bin:$GOROOT/bin

RUN wget -qO$GOPATH/bin/dep https://github.com/golang/dep/releases/download/v0.5.0/dep-linux-amd64 && \
      chmod +x $GOPATH/bin/dep

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
EXPOSE 8080
ENV SCONE_HEAP 2G
ENTRYPOINT ["/frontend/server"]
