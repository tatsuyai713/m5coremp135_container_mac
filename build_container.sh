#!/bin/bash
SCRIPT_DIR=$(cd $(dirname "$0") && pwd)
cd $SCRIPT_DIR
pwd

BASE_IMAGE="m5coremp135_base_image"
NAME_IMAGE="m5coremp135_image_${USER}"

if [ "$(docker image ls -q ${NAME_IMAGE})" ]; then
	echo "Docker image is already built!"
	exit
fi

echo "Build Container"

docker build --file=./Dockerfile -t $NAME_IMAGE . --build-arg UID=$(id -u) --build-arg GID=$(id -u) --build-arg UNAME=$USER --build-arg SETLOCALE='JP'


echo "_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/"
echo "_/Building container image is finished!!_/"
echo "_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/"
