#!/bin/bash

set -e

# You need a Secret to access private container registries.
# More info: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
K8S_IMAGE_PULL_SECRET="${K8S_IMAGE_PULL_SECRET:="sconeapps"}"

# Configure which device plugin to use (scone or azure).
DEVICE_PLUGIN=scone

# Configure Service type of "frontend", i.e., how to expose it (LoadBalancer or NodePort).
FRONTEND_SERVICE_TYPE="NodePort"

pushd "release"

# Deploy services.
for service in redis-cart adservice cartservice checkoutservice currencyservice emailservice paymentservice productcatalogservice recommendationservice shippingservice ; do

    # Remove old versions of the same chart.
    helm delete $service >/dev/null 2>&1 || true

    # Install chart.
    helm install $service charts/$service \
            --set useSGXDevPlugin="$DEVICE_PLUGIN" \
            --set imagePullSecrets[0].name="$K8S_IMAGE_PULL_SECRET"

    sleep 5
done

# Deploy frontend.
helm delete frontend >/dev/null 2>&1 || true

# Install chart.
helm install frontend charts/frontend \
        --set useSGXDevPlugin="$DEVICE_PLUGIN" \
        --set imagePullSecrets[0].name="$K8S_IMAGE_PULL_SECRET" \
        --set service.type="$FRONTEND_SERVICE_TYPE"
popd
