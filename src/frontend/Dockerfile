FROM golang:1.10-alpine AS builder

FROM sconecuratedimages/experimental:crosscompilers-alpine3.7

COPY --from=builder /usr/local/go/ /usr/local/go/

RUN apk add --no-cache --update git ca-certificates busybox-extras net-tools bind-tools

ENV GOPATH /go
ENV GOROOT /usr/local/go
ENV SCONE_HEAP 1G

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && \
      chmod -R 777 "$GOPATH"

ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

RUN wget -qO/go/bin/dep https://github.com/golang/dep/releases/download/v0.5.0/dep-linux-amd64 && \
      chmod +x /go/bin/dep

FROM golang:1.15-alpine as builder
RUN apk add --no-cache ca-certificates git
WORKDIR /src

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
ENTRYPOINT ["/frontend/server"]
