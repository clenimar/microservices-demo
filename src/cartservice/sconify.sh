set -x

# cartservice is not yet support by sconify (C#).
# Use a pre-built image with cartservice on SCONE.
CARTSERVICE_IMAGE="registry.scontain.com:5050/sconecuratedimages/cartservice:alpine"
TARGET_IMAGE=${TARGET_IMAGE:="cartservice-sconify"}

docker pull $CARTSERVICE_IMAGE
docker tag $CARTSERVICE_IMAGE $TARGET_IMAGE
docker push $TARGET_IMAGE

