#!/usr/bin/env bash

# reseta o banco
dropdb -h 172.17.0.1 -U postgres $1 || true
createdb -h 172.17.0.1 -U postgres $1
