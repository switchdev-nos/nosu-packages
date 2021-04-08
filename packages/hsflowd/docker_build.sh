#!/bin/bash

ENVFILE="./env/default"
[ -n "$1" ] && ENVFILE=$1
ENVFILE=$ENVFILE docker-compose run --rm nosu-pkg-hsflowd
