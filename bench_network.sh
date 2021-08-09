#!/bin/bash

DOCKER_CRUN_LOGS="./logs/docker_crun_nc.csv"
DOCKER_RUNC_LOGS="./logs/docker_runc_nc.csv"
PODMAN_CRUN_LOGS="./logs/podman_crun_nc.csv"
PODMAN_RUNC_LOGS="./logs/podman_runc_nc.csv"
ITERATIONS=50

DOCKER_PORT=10101
PODMAN_PORT=10102

if [ ! -f 1gb.img ]; then
    echo "Generating 1GB file..."
		dd if=/dev/urandom of=1gb.img bs=1 count=0 seek=1G
fi



# Podman + runc do not work currently 
# echo "Benchmarking Podman + runc"
# podman run -d --rm --log-driver=none --runtime=runc --name podman_nc -p $PODMAN_PORT:$PODMAN_PORT docker.io/appropriate/nc:latest -lk $PODMAN_PORT
# rm $PODMAN_RUNC_LOGS
# for i in `seq 1 $ITERATIONS`; do
# 	( { time nc -q 0 localhost $PODMAN_PORT < 1gb.img; } 2>&1) | grep real | cut -f2 >> $PODMAN_RUNC_LOGS
# 	sleep 1
# done
# podman rm -f podman_nc

echo "Benchmarking Docker + crun"
rm $DOCKER_CRUN_LOGS
docker run -d --rm --log-driver=none --runtime=crun --name docker_nc -p $DOCKER_PORT:$DOCKER_PORT appropriate/nc:latest -lk $DOCKER_PORT
for i in `seq 1 $ITERATIONS`; do
	( { time nc -q 0 localhost $DOCKER_PORT < 1gb.img; } 2>&1) | grep real | cut -f2 >> $DOCKER_CRUN_LOGS
	sleep 1
done
docker rm -f docker_nc
sleep 1


echo "Benchmarking Docker + runc"
rm $DOCKER_RUNC_LOGS
docker run -d --rm --log-driver=none --runtime=runc --name docker_nc -p $DOCKER_PORT:$DOCKER_PORT appropriate/nc:latest -lk $DOCKER_PORT
for i in `seq 1 $ITERATIONS`; do
	( { time nc -q 0 localhost $DOCKER_PORT < 1gb.img; } 2>&1) | grep real | cut -f2 >> $DOCKER_RUNC_LOGS
	sleep 1
done
docker rm -f docker_nc
sleep 1


echo "Benchmarking Podman + crun"
podman run -d --rm --log-driver=none --runtime=crun --name podman_nc -p $PODMAN_PORT:$PODMAN_PORT docker.io/appropriate/nc:latest -lk $PODMAN_PORT
rm $PODMAN_CRUN_LOGS
for i in `seq 1 $ITERATIONS`; do
	( { time nc -q 0 localhost $PODMAN_PORT < 1gb.img; } 2>&1) | grep real | cut -f2 >> $PODMAN_CRUN_LOGS
	sleep 1
done
podman rm -f podman_nc
sleep 1
