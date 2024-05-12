#!/bin/sh
SCRIPT_DIR=$(cd $(dirname "$0") && pwd)
cd $SCRIPT_DIR

NAME_IMAGE="m5coremp135_image_${USER}"
NAME_CONTAINER="m5coremp135_container_${USER}"

# Commit
if [ ! $# -ne 1 ]; then
	if [ "commit" = $1 ]; then
		docker commit ${NAME_CONTAINER} ${NAME_IMAGE}:latest
		CONTAINER_ID=$(docker ps -a -f name=${NAME_CONTAINER} --format "{{.ID}}")
		docker rm $CONTAINER_ID -f
		exit 0
	fi
fi

# Stop
if [ ! $# -ne 1 ]; then
	if [ "stop" = $1 ]; then
		CONTAINER_ID=$(docker ps -a -f name=${NAME_CONTAINER} --format "{{.ID}}")
		docker stop $CONTAINER_ID
		docker rm $CONTAINER_ID -f
		exit 0
	fi
fi

# Delete
if [ ! $# -ne 1 ]; then
	if [ "delete" = $1 ]; then
		echo 'Now deleting docker container...'
		CONTAINER_ID=$(docker ps -a -f name=${NAME_CONTAINER} --format "{{.ID}}")
		docker stop $CONTAINER_ID
		docker rm $CONTAINER_ID -f
		docker image rm ${NAME_IMAGE}
		exit 0
	fi
fi

XAUTH=/tmp/.docker.xauth
touch $XAUTH
xauth_list=$(xauth nlist :0 | sed -e 's/^..../ffff/')
if [ ! -z "$xauth_list" ];  then
  echo $xauth_list | xauth -f $XAUTH nmerge -
fi
chmod a+r $XAUTH

DOCKER_OPT=""
DOCKER_NAME="${NAME_CONTAINER}"
DOCKER_WORK_DIR="/home/${USER}"
MAC_WORK_DIR="/Users/${USER}"
DISPLAY=$(hostname):0

## For XWindow
DOCKER_OPT="${DOCKER_OPT} \
        --env=QT_X11_NO_MITSHM=1 \
        --volume=/tmp/.X11-unix:/tmp/.X11-unix:rw \
        --volume=/Users/${USER}:/home/${USER}/host_home:rw \
        --env=XAUTHORITY=${XAUTH} \
        --volume=${XAUTH}:${XAUTH} \
        --env=DISPLAY=${DISPLAY} \
		--shm-size=4gb \
		--env=TERM=xterm-256color \
        -w ${DOCKER_WORK_DIR} \
        -u ${USER} \
        --hostname Docker-`hostname` \
        --add-host Docker-`hostname`:127.0.1.1"


## Allow X11 Connection
xhost +local:`hostname`
CONTAINER_ID=$(docker ps -a -f name=${NAME_CONTAINER} --format "{{.ID}}")
if [ ! "$CONTAINER_ID" ]; then
	docker run ${DOCKER_OPT} \
		--name=${DOCKER_NAME} \
		--volume=$MAC_WORK_DIR/.Xauthority:$DOCKER_WORK_DIR/.Xauthority:rw \
		-it \
		--entrypoint /bin/bash \
		${NAME_IMAGE}:latest
else
	docker start $CONTAINER_ID
	docker exec -it $CONTAINER_ID /bin/bash
fi

xhost -local:`hostname`

