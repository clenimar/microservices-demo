#!/bin/bash

set -x

echo "Sconify: frontend"

# Build native image.
NATIVE_IMAGE="frontend"
docker build . -t "$NATIVE_IMAGE" -f gcc.Dockerfile

# Sconify native image.
TARGET_IMAGE=${TARGET_IMAGE:="frontend-sconify"}
SCONIFY_IMAGE=${SCONIFY_IMAGE_MUSL:=registry.scontain.com:5050/clenimar/sconify-image-dev:v6}
SCONE_CAS_ADDR=${SCONE_CAS_ADDR:="5-4-0.scone-cas.cf"}
CAS_NAMESPACE=${CAS_NAMESPACE:="online-boutique-$RANDOM$RANDOM"}
K8S_NAMESPACE=${K8S_NAMESPACE:="default"}

SCONE_HEAP="2G"
SCONE_ALLOW_DLOPEN="1"
GO_BINARY="/frontend/server"
SESSION_NAME="frontend"
CMD="/frontend/server"
SERVICE_NAME="frontend"

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
        --dir="/frontend/templates" \
        --dir="/frontend/static" \
        --heap="$SCONE_HEAP" \
        --dlopen="$SCONE_ALLOW_DLOPEN" \
        --env="DISABLE_PROFILER=1" \
        --env="DISABLE_STATS=1" \
        --env="DISABLE_TRACING=1" \
	--env="PRODUCT_CATALOG_SERVICE_ADDR=productcatalogservice-sconify-productcatalogservice.$K8S_NAMESPACE:3550" \
	--env="CURRENCY_SERVICE_ADDR=currencyservice-sconify-currencyservice.$K8S_NAMESPACE:7000" \
        --env="CART_SERVICE_ADDR=cartservice-sconify-cartservice.$K8S_NAMESPACE:7070" \
        --env="RECOMMENDATION_SERVICE_ADDR=recommendationservice-sconify-recommendationservice.$K8S_NAMESPACE:8080" \
        --env="SHIPPING_SERVICE_ADDR=shippingservice-sconify-shippingservice.$K8S_NAMESPACE:50051" \
        --env="CHECKOUT_SERVICE_ADDR=checkoutservice-sconify-checkoutservice.$K8S_NAMESPACE:5050" \
        --env="AD_SERVICE_ADDR=adservice-sconify-adservice.$K8S_NAMESPACE:9555" \
        --debug \
        --no-color \
	--push-image \
        --k8s-helm-workload-type="deployment" \
	--k8s-helm-expose="8080" \
	--k8s-helm-set="resources.limits.memory=4G" \
        --k8s-helm-output="/charts"
