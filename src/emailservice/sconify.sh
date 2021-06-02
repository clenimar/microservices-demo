#!/bin/bash

set -x

echo "Sconify: emailservice"

# Build native image.
NATIVE_IMAGE="emailservice"
docker build . -t "$NATIVE_IMAGE"

# Sconify native image.
BASE_IMAGE="python:3.7-slim"
TARGET_IMAGE=${TARGET_IMAGE:="emailservice-sconify"}
SCONIFY_IMAGE=${SCONIFY_IMAGE_GLIBC:="registry.scontain.com:5050/clenimar/sconify-image-dev:v7-glibc-libs"}
SCONE_CAS_ADDR=${SCONE_CAS_ADDR:="5-4-0.scone-cas.cf"}
CAS_NAMESPACE=${CAS_NAMESPACE:="online-boutique-$RANDOM$RANDOM"}
K8S_NAMESPACE=${K8S_NAMESPACE:="default"}

PYTHON_BINARY="/usr/local/bin/python3.7"
CMD="python /email_server/email_server.py"
SESSION_NAME="emailservice"
SERVICE_NAME="emailservice"
SCONE_HEAP="1G"
SCONE_ALLOW_DLOPEN="1"

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
	--base="$BASE_IMAGE" \
        --binary="$PYTHON_BINARY" \
        --namespace="$CAS_NAMESPACE" \
        --cli="$SCONIFY_IMAGE" \
        --crosscompiler="$SCONIFY_IMAGE" \
        --cas="$SCONE_CAS_ADDR" \
        --cas-debug \
	--binary-fs \
        --fs-dir="/email_server" \
        --fs-dir="/usr/local/lib" \
        --fs-dir="/usr/lib/x86_64-linux-gnu" \
	--host-path="/etc/resolv.conf" \
        --heap="$SCONE_HEAP" \
        --dlopen="$SCONE_ALLOW_DLOPEN" \
        --env="PORT=8080" \
        --env="DISABLE_TRACING=1" \
        --env="DISABLE_PROFILER=1" \
	--env="LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:/usr/local/lib" \
        --debug \
        --no-color \
	--push-image \
        --k8s-helm-workload-type="deployment" \
	--k8s-helm-expose="8080" \
	--k8s-helm-set="resources.limits.memory=2G" \
        --k8s-helm-output="/charts"
