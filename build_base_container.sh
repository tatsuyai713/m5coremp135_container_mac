#!/bin/bash

NAME_IMAGE="m5coremp135_base_image"
echo "Build Base Container"

# docker build -f common.dockerfile -t ghcr.io/tatsuyai713/${NAME_IMAGE}:v0.01 .
docker import --platform linux/arm/v7 ./m5_rootfs_20240515.tar.gz ghcr.io/tatsuyai713/m5coremp135:20240515
docker push ghcr.io/tatsuyai713/m5coremp135:20240515