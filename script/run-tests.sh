#!/bin/bash
source /home/app/perl5/perlbrew/etc/bashrc

mkdir -p /data/log/;

cd /src;

if [ -f envfile_local.sh ]; then
    echo 'foo';
    source envfile_local.sh
else
echo 'bar';
    source envfile.sh
fi

cpanm -n . --installdeps
sqitch deploy -t $SQITCH_DEPLOY

forkprove -MPrep -j 8 -lrv ./t/