#!/usr/bin/env bash
set -e

if [[ -z $1 ]]; then
  echo "Must set a python version to build."
  exit 1
fi

# Version- the python version itself (3.7, 3.8, 3.9.7, etc)
# Build Target - the upstream container to use during the building stage
# Publish Target - the upstream container to use for the final stage


if [[ $1 =~ "latest" ]]; then
  VERSION="3.10"
  PUBLISH_TARGET="latest"
  BUILD_TARGET=$PUBLISH_TARGET
else
  VERSION=$1
  BUILD_TARGET=$VERSION

  # Set image PUBLISH_TARGET version- ie, 3.9-slim.
  if [[ ! -z $2 ]]; then
    PUBLISH_TARGET=$VERSION-$2
  else
    PUBLISH_TARGET=$VERSION
  fi

  # Set build environment for uvloop
  if [[ $PUBLISH_TARGET =~ "alpine" ]]; then
    # Alpine is the odd one out- everything else is ubuntu.
    # So the build environment has to also be alpine.
    BUILD_TARGET=$PUBLISH_TARGET
  else
    # Every other image should use the full container for builds.
    BUILD_TARGET=$VERSION
  fi

fi

# Image Push location
REGISTRY=${REGISTRY:-"ghcr.io"}
IMAGE_NAME=${IMAGE_NAME:-"tedivm/python-uvicorn"}
IMAGE_LOCATION=$REGISTRY/$IMAGE_NAME
TAG=$IMAGE_LOCATION:$PUBLISH_TARGET

if [[ "$VERSION" == "3.10" ]] && [[ "$VERSION" == "$BUILD_TARGET" ]] && [[ "$VERSION" == "$BUILD_TARGET" ]]; then
  LATEST_TAG="-t $IMAGE_LOCATION:LATEST"
else
  LATEST_TAG=""
fi

echo Building and pushing $TAG
echo Python Version: $VERSION
echo Publish Target: $PUBLISH_TARGET
echo Build Target: $BUILD_TARGET

docker buildx use multiarch ||  docker buildx create --name multiarch --use

docker buildx build \
  --platform "linux/amd64,linux/arm64,linux/arm/v7" \
  -t "$TAG"  \
  -t "$TAG-$(date +%y.%m.%d)"  \
  $LATEST_TAG \
  --build-arg version=$VERSION \
  --build-arg publish_target=$PUBLISH_TARGET \
  --build-arg build_target=$BUILD_TARGET \
  --push \
  .
