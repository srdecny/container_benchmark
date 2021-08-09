#!/bin/bash
echo "Pulling down tested images"
./pull.sh

echo "Docker + crun"
./bench_init.sh docker crun
echo "Podman + crun"
./bench_init.sh podman crun
echo "Docker + runc"
./bench_init.sh docker runc
# Podman + runc do not work currently together
# echo "Podman + runc"
# ./bench_init.sh podman runc

./bench_network.sh

python3 plot.py