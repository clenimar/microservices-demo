FROM sconecuratedimages/crosscompilers:alpine3.7

RUN apk add --no-cache --update ca-certificates git go

ENV GOPATH /root/go
RUN mkdir -p $GOPATH/bin
ENV PATH $PATH:$GOPATH/bin

RUN wget -qO$GOPATH/bin/dep https://github.com/golang/dep/releases/download/v0.5.0/dep-linux-amd64 && \
      chmod +x $GOPATH/bin/dep

ENV PROJECT github.com/GoogleCloudPlatform/microservices-demo/src/shippingservice

WORKDIR $GOPATH/src/$PROJECT

# restore dependencies
COPY Gopkg.* ./
RUN dep ensure --vendor-only -v

COPY . .
RUN go build -compiler gccgo -buildmode=exe -gccgoflags -g -o /shippingservice .

RUN GRPC_HEALTH_PROBE_VERSION=v0.2.0 && \
    wget -qO/bin/grpc_health_probe https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/${GRPC_HEALTH_PROBE_VERSION}/grpc_health_probe-linux-amd64 && \
    chmod +x /bin/grpc_health_probe

ENV APP_PORT=50051
EXPOSE 50051
ENV SCONE_HEAP 1G
ENTRYPOINT ["/shippingservice"]

