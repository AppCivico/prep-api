#!/bin/bash
cd /src;
source /home/app/perl5/perlbrew/etc/bashrc;

if [ -f envfile_local.sh ]; then
    source envfile_local.sh
else
    source envfile.sh
fi

export SQITCH_DEPLOY=${SQITCH_DEPLOY:=docker}

cpanm -nv . --installdeps
sqitch deploy -t $SQITCH_DEPLOY

hypnotoad script/prep_api

