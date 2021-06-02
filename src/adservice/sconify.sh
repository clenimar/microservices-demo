#!/bin/bash

set -x

echo "Sconify: adservice"

# Build native image.
NATIVE_IMAGE="adservice"
docker build . -t "$NATIVE_IMAGE"

# Sconify native image.
BASE_IMAGE="openjdk:8-slim"
TARGET_IMAGE=${TARGET_IMAGE:="adservice-sconify"}
SCONIFY_IMAGE=${SCONIFY_IMAGE_GLIBC:="registry.scontain.com:5050/clenimar/sconify-image-dev:v7-glibc-libs"}
SCONE_CAS_ADDR=${SCONE_CAS_ADDR:="5-4-0.scone-cas.cf"}
CAS_NAMESPACE=${CAS_NAMESPACE:="online-boutique-$RANDOM$RANDOM"}
K8S_NAMESPACE=${K8S_NAMESPACE:="default"}

SCONE_HEAP="8G"
SCONE_ALLOW_DLOPEN="1"
SCONE_FORK="1"
JAVA_HOME="/usr/local/openjdk-8"
JAVA_BINARY="$JAVA_HOME""/bin/java"
SESSION_NAME="adservice"
CMD="/usr/local/openjdk-8/bin/java -Dlog4j2.contextDataInjector=io.opencensus.contrib.logcorrelation.log4j2.OpenCensusTraceContextDataInjector -agentpath:/opt/cprof/profiler_java_agent.so=-cprof_service=adservice,-cprof_service_version=1.0.0 -classpath /app/build/install/hipstershop/lib/hipstershop-0.1.0-SNAPSHOT.jar:/app/build/install/hipstershop/lib/grpc-services-1.32.1.jar:/app/build/install/hipstershop/lib/opencensus-exporter-stats-stackdriver-0.27.0.jar:/app/build/install/hipstershop/lib/google-cloud-monitoring-1.82.0.jar:/app/build/install/hipstershop/lib/opencensus-exporter-trace-stackdriver-0.27.0.jar:/app/build/install/hipstershop/lib/google-cloud-trace-0.100.0-beta.jar:/app/build/install/hipstershop/lib/google-cloud-core-grpc-1.82.0.jar:/app/build/install/hipstershop/lib/gax-grpc-1.47.1.jar:/app/build/install/hipstershop/lib/grpc-alts-1.21.0.jar:/app/build/install/hipstershop/lib/grpc-grpclb-1.21.0.jar:/app/build/install/hipstershop/lib/grpc-protobuf-1.32.1.jar:/app/build/install/hipstershop/lib/proto-google-cloud-monitoring-v3-1.64.0.jar:/app/build/install/hipstershop/lib/proto-google-cloud-trace-v1-0.65.0.jar:/app/build/install/hipstershop/lib/proto-google-cloud-trace-v2-0.65.0.jar:/app/build/install/hipstershop/lib/google-cloud-core-1.82.0.jar:/app/build/install/hipstershop/lib/proto-google-iam-v1-0.12.0.jar:/app/build/install/hipstershop/lib/proto-google-common-protos-1.18.1.jar:/app/build/install/hipstershop/lib/opencensus-contrib-grpc-metrics-0.27.0.jar:/app/build/install/hipstershop/lib/opencensus-contrib-grpc-util-0.27.0.jar:/app/build/install/hipstershop/lib/opencensus-exporter-trace-jaeger-0.27.0.jar:/app/build/install/hipstershop/lib/opencensus-exporter-trace-logging-0.27.0.jar:/app/build/install/hipstershop/lib/opencensus-contrib-log-correlation-log4j2-0.27.0.jar:/app/build/install/hipstershop/lib/opencensus-impl-0.27.0.jar:/app/build/install/hipstershop/lib/opencensus-exporter-trace-util-0.27.0.jar:/app/build/install/hipstershop/lib/opencensus-contrib-exemplar-util-0.27.0.jar:/app/build/install/hipstershop/lib/opencensus-contrib-resource-util-0.27.0.jar:/app/build/install/hipstershop/lib/opencensus-exporter-metrics-util-0.27.0.jar:/app/build/install/hipstershop/lib/opencensus-impl-core-0.27.0.jar:/app/build/install/hipstershop/lib/opencensus-api-0.27.0.jar:/app/build/install/hipstershop/lib/grpc-stub-1.32.1.jar:/app/build/install/hipstershop/lib/grpc-netty-1.32.1.jar:/app/build/install/hipstershop/lib/log4j-core-2.13.3.jar:/app/build/install/hipstershop/lib/jackson-annotations-2.12.1.jar:/app/build/install/hipstershop/lib/jackson-databind-2.12.1.jar:/app/build/install/hipstershop/lib/gax-1.47.1.jar:/app/build/install/hipstershop/lib/google-auth-library-oauth2-http-0.16.2.jar:/app/build/install/hipstershop/lib/google-http-client-jackson2-1.30.1.jar:/app/build/install/hipstershop/lib/jackson-core-2.12.1.jar:/app/build/install/hipstershop/lib/netty-tcnative-boringssl-static-2.0.34.Final.jar:/app/build/install/hipstershop/lib/protobuf-java-util-3.12.0.jar:/app/build/install/hipstershop/lib/protobuf-java-3.12.2.jar:/app/build/install/hipstershop/lib/grpc-auth-1.27.2.jar:/app/build/install/hipstershop/lib/grpc-protobuf-lite-1.32.1.jar:/app/build/install/hipstershop/lib/grpc-netty-shaded-1.27.2.jar:/app/build/install/hipstershop/lib/grpc-core-1.32.1.jar:/app/build/install/hipstershop/lib/grpc-api-1.32.1.jar:/app/build/install/hipstershop/lib/grpc-context-1.32.1.jar:/app/build/install/hipstershop/lib/guava-29.0-android.jar:/app/build/install/hipstershop/lib/jaeger-client-0.33.1.jar:/app/build/install/hipstershop/lib/google-auth-library-credentials-0.20.0.jar:/app/build/install/hipstershop/lib/perfmark-api-0.19.0.jar:/app/build/install/hipstershop/lib/jsr305-3.0.2.jar:/app/build/install/hipstershop/lib/error_prone_annotations-2.3.4.jar:/app/build/install/hipstershop/lib/animal-sniffer-annotations-1.18.jar:/app/build/install/hipstershop/lib/netty-codec-http2-4.1.51.Final.jar:/app/build/install/hipstershop/lib/netty-handler-proxy-4.1.51.Final.jar:/app/build/install/hipstershop/lib/log4j-api-2.13.3.jar:/app/build/install/hipstershop/lib/disruptor-3.4.2.jar:/app/build/install/hipstershop/lib/failureaccess-1.0.1.jar:/app/build/install/hipstershop/lib/listenablefuture-9999.0-empty-to-avoid-conflict-with-guava.jar:/app/build/install/hipstershop/lib/checker-compat-qual-2.5.5.jar:/app/build/install/hipstershop/lib/google-http-client-1.30.1.jar:/app/build/install/hipstershop/lib/j2objc-annotations-1.3.jar:/app/build/install/hipstershop/lib/jaeger-thrift-0.33.1.jar:/app/build/install/hipstershop/lib/jaeger-tracerresolver-0.33.1.jar:/app/build/install/hipstershop/lib/jaeger-core-0.33.1.jar:/app/build/install/hipstershop/lib/gson-2.8.6.jar:/app/build/install/hipstershop/lib/annotations-4.1.1.4.jar:/app/build/install/hipstershop/lib/netty-codec-http-4.1.51.Final.jar:/app/build/install/hipstershop/lib/netty-handler-4.1.51.Final.jar:/app/build/install/hipstershop/lib/netty-codec-socks-4.1.51.Final.jar:/app/build/install/hipstershop/lib/netty-codec-4.1.51.Final.jar:/app/build/install/hipstershop/lib/netty-transport-4.1.51.Final.jar:/app/build/install/hipstershop/lib/netty-buffer-4.1.51.Final.jar:/app/build/install/hipstershop/lib/netty-resolver-4.1.51.Final.jar:/app/build/install/hipstershop/lib/netty-common-4.1.51.Final.jar:/app/build/install/hipstershop/lib/libthrift-0.11.0.jar:/app/build/install/hipstershop/lib/slf4j-api-1.7.25.jar:/app/build/install/hipstershop/lib/okhttp-3.9.0.jar:/app/build/install/hipstershop/lib/opentracing-util-0.31.0.jar:/app/build/install/hipstershop/lib/opentracing-tracerresolver-0.1.5.jar:/app/build/install/hipstershop/lib/opentracing-noop-0.31.0.jar:/app/build/install/hipstershop/lib/opentracing-api-0.31.0.jar:/app/build/install/hipstershop/lib/api-common-1.8.1.jar:/app/build/install/hipstershop/lib/javax.annotation-api-1.3.2.jar:/app/build/install/hipstershop/lib/httpclient-4.5.8.jar:/app/build/install/hipstershop/lib/httpcore-4.4.11.jar:/app/build/install/hipstershop/lib/okio-1.13.0.jar:/app/build/install/hipstershop/lib/threetenbp-1.3.3.jar:/app/build/install/hipstershop/lib/commons-logging-1.2.jar:/app/build/install/hipstershop/lib/commons-codec-1.11.jar:/app/build/install/hipstershop/lib/opencensus-contrib-http-util-0.21.0.jar:/app/build/install/hipstershop/lib/commons-lang3-3.5.jar hipstershop.AdService"
SERVICE_NAME="adservice"

docker run -it --rm \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v $HOME/.docker/config.json:/root/.docker/config.json \
    -v $PWD/../../release/charts:/charts \
    $SCONIFY_IMAGE \
    sconify_image \
        --from="$NATIVE_IMAGE" \
        --to="$TARGET_IMAGE" \
        --command="$CMD" \
        --service-name="$SERVICE_NAME" \
        --binary="$JAVA_BINARY" \
	--base="$BASE_IMAGE" \
        --namespace="$CAS_NAMESPACE" \
        --cli="$SCONIFY_IMAGE" \
        --crosscompiler="$SCONIFY_IMAGE" \
        --cas="$SCONE_CAS_ADDR" \
        --cas-debug \
        --dir="/app" \
	--dir="/opt/cprof" \
	--dir="/usr/local/openjdk-8/jre/lib/amd64" \
	--dir="/lib/x86_64-linux-gnu" \
	--plain-file="/app/build/install/hipstershop/bin/AdService" \
        --heap="$SCONE_HEAP" \
        --dlopen="$SCONE_ALLOW_DLOPEN" \
	--fork="$SCONE_FORK" \
	--disable-copy-service-libraries \
        --plain="$JAVA_HOME" \
        --env="PORT=3550" \
        --env="DISABLE_TRACING=1" \
        --env="DISABLE_PROFILER=1" \
        --env="DISABLE_DEBUGGER=1" \
	--env="DISABLE_STATS=1" \
	--env="JAVA_TOOL_OPTION=-Xmx512M" \
	--push-image \
        --debug \
        --no-color \
        --k8s-helm-workload-type="deployment" \
        --k8s-helm-output="/charts" \
	--k8s-helm-expose="3550" \
	--k8s-helm-set="resources.limits.memory=10G"
