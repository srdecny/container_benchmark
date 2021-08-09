#!/bin/bash
# Pull down the two images used in benchmarking, so they won't be dowloaded on the first run of the benchmark.

ALPINE="docker.io/library/alpine:3.14.1"
POSTGRES="docker.io/library/postgres:11.1"
NC="docker.io/appropriate/nc:latest"

docker pull $ALPINE
docker pull $POSTGRES
docker pull $NC

podman pull $ALPINE
podman pull $POSTGRES
podman pull $NC