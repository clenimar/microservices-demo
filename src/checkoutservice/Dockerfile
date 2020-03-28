FROM sconecuratedimages/experimental:crosscompilers-alpine3.7

#COPY --from=builder /usr/local/go/ /usr/local/go/

#RUN apk add --no-cache --update git ca-certificates 
RUN apk add --no-cache --update git ca-certificates go

#ENV GOPATH /go
ENV GOPATH /root/go
#ENV GOROOT /usr/local/go
#ENV GOROOT /usr/local/go

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && \
      chmod -R 777 "$GOPATH"

ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

RUN wget -qO${GOPATH}/bin/dep https://github.com/golang/dep/releases/download/v0.5.0/dep-linux-amd64 && \
      chmod +x ${GOPATH}/bin/dep

ENV PROJECT github.com/GoogleCloudPlatform/microservices-demo/src/checkoutservice

WORKDIR ${GOPATH}/src/$PROJECT

# restore dependencies
COPY go.mod go.sum ./
RUN go mod download

RUN go version

ENV SCONE_HEAP 1G

COPY . .
RUN go build -compiler gccgo -buildmode=exe -gccgoflags -g -o /checkoutservice .

RUN GRPC_HEALTH_PROBE_VERSION=v0.2.0 && \
    wget -qO/bin/grpc_health_probe https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/${GRPC_HEALTH_PROBE_VERSION}/grpc_health_probe-linux-amd64 && \
    chmod +x /bin/grpc_health_probe
EXPOSE 5050
ENTRYPOINT ["/checkoutservice"]
