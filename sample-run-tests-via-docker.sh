#!/usr/bin/env bash
docker run --rm -it -u app -v $(pwd):/src -v /tmp/prep-tmp-data:/data appcivico/prep_api /src/script/run-tests.sh
