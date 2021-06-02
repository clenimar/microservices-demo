#!/bin/bash

set -x

echo "Sconify: checkoutservice"

# Build native image.
NATIVE_IMAGE="checkoutservice"
docker build . -t "$NATIVE_IMAGE" -f gcc.Dockerfile

# Sconify native image.
TARGET_IMAGE=${TARGET_IMAGE:="checkoutservice-sconify"}
SCONIFY_IMAGE=${SCONIFY_IMAGE_MUSL:="registry.scontain.com:5050/clenimar/sconify-image-dev:v6"}
SCONE_CAS_ADDR=${SCONE_CAS_ADDR:="5-4-0.scone-cas.cf"}
CAS_NAMESPACE=${CAS_NAMESPACE:="online-boutique-$RANDOM$RANDOM"}
K8S_NAMESPACE=${K8S_NAMESPACE:="default"}

SCONE_HEAP="2G"
SCONE_ALLOW_DLOPEN="1"
GO_BINARY="/checkoutservice"
SESSION_NAME="checkoutservice"
CMD="/checkoutservice"
SERVICE_NAME="checkoutservice"

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
        --heap="$SCONE_HEAP" \
        --dlopen="$SCONE_ALLOW_DLOPEN" \
        --env="PORT=5050" \
        --env="PRODUCT_CATALOG_SERVICE_ADDR=productcatalogservice-sconify-productcatalogservice.$K8S_NAMESPACE:3550" \
        --env="SHIPPING_SERVICE_ADDR=shippingservice-sconify-shippingservice.$K8S_NAMESPACE:50051" \
        --env="PAYMENT_SERVICE_ADDR=paymentservice-sconify-paymentservice.$K8S_NAMESPACE:50051" \
        --env="EMAIL_SERVICE_ADDR=emailservice-sconify-emailservice.$K8S_NAMESPACE:5000" \
        --env="CURRENCY_SERVICE_ADDR=currencyservice-sconify-currencyservice.$K8S_NAMESPACE:7000" \
        --env="CART_SERVICE_ADDR=cartservice-sconify-cartservice.$K8S_NAMESPACE:7070" \
        --debug \
        --no-color \
	--push-image \
        --k8s-helm-workload-type="deployment" \
	--k8s-helm-expose="5050" \
	--k8s-helm-set="resources.limits.memory=4G" \
        --k8s-helm-output="/charts"
