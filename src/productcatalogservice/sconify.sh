#!/bin/bash

set -xe

echo "Sconify: productcatalogservice"

# Build native image.
NATIVE_IMAGE="productcatalogservice"
docker build . -t "$NATIVE_IMAGE" -f gcc.Dockerfile

# Sconify native image.
TARGET_IMAGE=${TARGET_IMAGE:="productcatalogservice-sconify"}
SCONIFY_IMAGE=${SCONIFY_IMAGE_MUSL:=registry.scontain.com:5050/clenimar/sconify-image-dev:v6}
SCONE_CAS_ADDR=${SCONE_CAS_ADDR:="5-4-0.scone-cas.cf"}
CAS_NAMESPACE=${CAS_NAMESPACE:="online-boutique-$RANDOM$RANDOM"}
K8S_NAMESPACE=${K8S_NAMESPACE:="default"}

SCONE_HEAP="2G"
SCONE_ALLOW_DLOPEN="1"
GO_BINARY="/productcatalogservice/server"
SESSION_NAME="productcatalogservice"
CMD="/productcatalogservice/server"
SERVICE_NAME="productcatalogservice"

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
        --binary="$GO_BINARY" \
        --namespace="$CAS_NAMESPACE" \
        --cli="$SCONIFY_IMAGE" \
        --crosscompiler="$SCONIFY_IMAGE" \
        --cas="$SCONE_CAS_ADDR" \
        --cas-debug \
        --dlopen="$SCONE_ALLOW_DLOPEN" \
	--dir="/productcatalogservice" \
        --env="PORT=3550" \
        --env="DISABLE_TRACING=1" \
        --env="DISABLE_PROFILER=1" \
        --env="DISABLE_DEBUGGER=1" \
        --debug \
        --no-color \
	--push-image \
        --k8s-helm-workload-type="deployment" \
	--k8s-helm-expose="3550" \
	--k8s-helm-set="resources.limits.memory=2.2G" \
        --k8s-helm-output="/charts"
