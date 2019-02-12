#!/bin/bash -e
cp Makefile.PL docker/Makefile_local.PL

docker build -t appcivico/prep_api docker/