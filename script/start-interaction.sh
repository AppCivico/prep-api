#!/bin/bash
source /home/app/perl5/perlbrew/etc/bashrc

mkdir -p /data/log/;

cd /src;
if [ -f envfile_local.sh ]; then
    source envfile_local.sh
else
    source envfile.sh
fi

cpanm -nv . --installdeps

perl script/daemon/interaction.pl
