#!/usr/bin/env bash
set -e

cd $WORKSPACE;
. ./build-container.sh

export DB_NAME='prep_testing'

mkdir -p $WORKSPACE/tmp-data
chown 1000:1000 $WORKSPACE/tmp-data -R
chown 1000:1000 $WORKSPACE/ -R

# config do banco
cp envfile.sh envfile_local.sh
sed -i "s/prep_api_dev/$DB_NAME/g" envfile_local.sh
sed -i "s/prep_api_dev/$DB_NAME/g" sqitch.conf

# como estou rodando o jenkins dentro de um container,
# é necessário do path no lado do host para executar o mount corretamente
export REAL_WORKSPACE="/home/jenkins-data/workspace/$JOB_NAME/"

# como dentro do jenkins, nao temos os comandos, vamos rodar por dentro do docker..
docker run --rm -i -u app -v $REAL_WORKSPACE:/src appcivico/prep_api /src/script/ci/resetdb.sh $DB_NAME

# roda os testes
docker run --rm -i -u app -v $REAL_WORKSPACE:/src -v $REAL_WORKSPACE/tmp-data:/data appcivico/prep_api /src/script/run-tests.sh

rm -rf $WORKSPACE/tmp-data
docker run --rm -i -u app -v $REAL_WORKSPACE:/src appcivico/prep_api /src/script/ci/dropdb.sh $DB_NAME
