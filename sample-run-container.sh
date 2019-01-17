#!/bin/bash

# arquivo de exemplo para iniciar o container
export SOURCE_DIR='/home/lucas-eokoe/projects/prep_api'
export DATA_DIR='/tmp/prep_api/data/'

mkdir -p $DATA_DIR

# confira o seu ip usando ifconfig docker0|grep 'inet addr:'
export DOCKER_LAN_IP=172.17.0.1

# porta que será feito o bind
export LISTEN_PORT=8181

docker run --name prep_api \
 -v $SOURCE_DIR:/src -v $DATA_DIR:/data \
 -p $DOCKER_LAN_IP:$LISTEN_PORT:8080 \
 --cpu-shares=512 \
 --memory 1800m -d --restart unless-stopped appcivico/prep_api

