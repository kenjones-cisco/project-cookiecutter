#!/bin/bash

IMAGE_NAME="${IMAGE_NAME:?missing required input \'IMAGE_NAME\'}"
VERSION="${VERSION:?missing required input \'VERSION\'}"

IMAGE_VERSION="${VERSION}"
if [[ ${PRERELEASE} != "" ]]; then
    IMAGE_VERSION=$(git describe --tags --always)
fi

GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

build_image() {
    docker build -t "${IMAGE_NAME}" --build-arg VERSION="${VERSION}" .
    docker tag "${IMAGE_NAME}" "${IMAGE_NAME}:${IMAGE_VERSION}"
}

publish_image() {
    # push the specific tag version
    docker push "${IMAGE_NAME}:${IMAGE_VERSION}"
    # push the latest tag
    docker push "${IMAGE_NAME}:latest"
}

PUB='false'
case "$1" in
    --publish)
        PUB='true'
        ;;
    *)
        ;;
esac

echo "IMAGE_NAME = ${IMAGE_NAME}"
echo "IMAGE_VERSION = ${IMAGE_VERSION}"

case "${GIT_BRANCH}" in
    develop)
        if [[ ${PRERELEASE} != "" ]]; then
            build_image
            if [[ "${PUB}" == *"true"* ]]; then
                publish_image
            fi
        fi
        ;;
    master)
        if [[ ${PRERELEASE} == "" ]]; then
            build_image
            if [[ "${PUB}" == *"true"* ]]; then
                publish_image
            fi
        fi
        ;;
    *)
        build_image
        ;;
esac
