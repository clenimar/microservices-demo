set -xe

# Images.
export SCONIFY_IMAGE_MUSL="registry.scontain.com:5050/clenimar/sconify-image-dev:v7"
export SCONIFY_IMAGE_GLIBC="registry.scontain.com:5050/clenimar/sconify-image-dev:v7-glibc-libs"
docker pull $SCONIFY_IMAGE_MUSL || echo "Failed to pull ""$SCONIFY_IMAGE_MUSL"". Please make sure you have access."
docker pull $SCONIFY_IMAGE_GLIBC || echo "Failed to pull ""$SCONIFY_IMAGE_GLIBC"". Please make sure you have access."

# Common variables.
export IMAGE_REPOSITORY="registry.scontain.com:5050/clenimar/test"
export SCONE_CAS_ADDR=${SCONE_CAS_ADDR:="5-4-0.scone-cas.cf"}
export CAS_MRENCLAVE=${CAS_MRENCLAVE:="9f82c11af7ed3c3212483a5ad33b59923ca1462d1814943ff2586932c21fa51b"}
export CAS_NAMESPACE="online-boutique-$RANDOM$RANDOM"

# Deployment variables.
export K8S_NAMESPACE="default"

# Create namespace.
docker run -it --rm \
    -v $PWD/policies:/policies \
    -e SCONE_CAS_ADDR=$SCONE_CAS_ADDR \
    -e CAS_NAMESPACE=$CAS_NAMESPACE \
    -e CAS_MRENCLAVE=$CAS_MRENCLAVE \
    ${SCONIFY_IMAGE_MUSL} \
    bash -c "/policies/upload_policies.sh"

# Update Helm chart for cartservice and redis-cart with updated Config ID.
sed -i 's/online-boutique-[0-9]\+/'"$CAS_NAMESPACE"'/g' release/charts/cartservice/values.yaml
sed -i 's/online-boutique-[0-9]\+/'"$CAS_NAMESPACE"'/g' release/charts/redis-cart/values.yaml

# Sconify services.
for service in adservice cartservice checkoutservice currencyservice emailservice frontend paymentservice productcatalogservice recommendationservice shippingservice ; do
        pushd "./src/""$service"
        TARGET_IMAGE="$IMAGE_REPOSITORY"":""$service""$CAS_NAMESPACE" ./sconify.sh
        popd
done

