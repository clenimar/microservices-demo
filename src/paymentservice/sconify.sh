#!/bin/bash

set -x

echo "Sconify: paymentservice"

# Build native image.
NATIVE_IMAGE="paymentservice"
docker build . -t "$NATIVE_IMAGE"

# Sconify native image.
TARGET_IMAGE=${TARGET_IMAGE:="paymentservice-sconify"}
SCONIFY_IMAGE=${SCONIFY_IMAGE_MUSL:=registry.scontain.com:5050/clenimar/sconify-image-dev:v6}
SCONE_CAS_ADDR=${SCONE_CAS_ADDR:="5-4-0.scone-cas.cf"}
CAS_NAMESPACE=${CAS_NAMESPACE:="online-boutique-$RANDOM$RANDOM"}
K8S_NAMESPACE=${K8S_NAMESPACE:="default"}

SCONE_HEAP="2G"
SCONE_FORK="0"
SCONE_ALLOW_DLOPEN="1"
NODE_BINARY="/usr/local/bin/node"
SESSION_NAME="paymentservice"
CMD="node index.js"
SERVICE_NAME="paymentservice"

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
        --binary="$NODE_BINARY" \
        --namespace="$CAS_NAMESPACE" \
        --cli="$SCONIFY_IMAGE" \
        --crosscompiler="$SCONIFY_IMAGE" \
        --cas="$SCONE_CAS_ADDR" \
        --cas-debug \
        --dir="/usr/src/app" \
        --heap="$SCONE_HEAP" \
        --dlopen="$SCONE_ALLOW_DLOPEN" \
	--fork="$SCONE_FORK" \
        --env="PORT=50051" \
        --env="DISABLE_TRACING=1" \
        --env="DISABLE_DEBUGGER=1" \
        --env="DISABLE_PROFILER=1" \
        --debug \
        --no-color \
	--push-image \
        --k8s-helm-workload-type="deployment" \
	--k8s-helm-expose="50051" \
	--k8s-helm-set="resources.limits.memory=4.5G" \
        --k8s-helm-output="/charts"
