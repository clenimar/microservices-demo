FROM sconecuratedimages/crosscompilers:alpine3.7

RUN apk add --no-cache --update \
        bind-tools \
        busybox-extras \
        ca-certificates \
        net-tools \
        git \
        go

ENV GOPATH /root/go
RUN mkdir -p $GOPATH/bin
ENV PATH $PATH:$GOPATH/bin

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
ENV SCONE_HEAP 1G
ENTRYPOINT ["/frontend/server"]
