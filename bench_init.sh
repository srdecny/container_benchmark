#!/bin/bash
trap "echo Exited!; exit;" SIGINT SIGTERM

# Save the timezone, so timestamps from the host and the container can be compared
TIMEZONE=`cat /etc/timezone`
ITERATIONS=50
SLEEP_BETWEEN=1

SLEEP_BETWEEN() {
	if [ $SLEEP_BETWEEN -ne 0 ]; then
		sleep 1
	fi
}

if [ "$1" == "docker" ] ; then
	CMD="docker run"
	POSTGRES_RUNC_LOG='./logs/docker_init_postgres_runc.csv'
	POSTGRES_CRUN_LOG='./logs/docker_init_postgres_crun.csv'
	ALPINE_RUNC_LOG='./logs/docker_init_alpine_runc.csv'
	ALPINE_CRUN_LOG='./logs/docker_init_alpine_crun.csv'
elif [ "$1" == "podman" ] ; then
	CMD="podman run --log-driver=none"
	POSTGRES_RUNC_LOG='./logs/podman_init_postgres_runc.csv'
	POSTGRES_CRUN_LOG='./logs/podman_init_postgres_crun.csv'
	ALPINE_RUNC_LOG='./logs/podman_init_alpine_runc.csv'
	ALPINE_CRUN_LOG='./logs/podman_init_alpine_crun.csv'
else
	echo "First argument must be docker or podman"
	exit 1
fi

if [ "$2" == "runc" ] ; then

	rm $POSTGRES_RUNC_LOG
	for i in `seq 1 $ITERATIONS`; do
		start=`date +%s%N`
		end=$($CMD -it --runtime=runc --rm -e TZ=$timezone postgres:11.1 /bin/bash -c 'date +%s%N')
		echo $start","$end >> $POSTGRES_RUNC_LOG
		SLEEP_BETWEEN
	done

	rm $ALPINE_RUNC_LOG
	for i in `seq 1 $ITERATIONS`; do
		start=`date +%s%N`
		# https://stackoverflow.com/a/38872276
		end=$($CMD -it --runtime=runc --rm -e TZ=$timezone alpine:3.14.1 /bin/sh -c "adjtimex | awk '/(time.tv_sec|time.tv_usec):/ { printf(\"%06d\", \$2) }'")
		echo $start","$end >> $ALPINE_RUNC_LOG
		SLEEP_BETWEEN
	done

elif [ "$2" == "crun" ] ; then

	rm $POSTGRES_CRUN_LOG
	for i in `seq 1 $ITERATIONS`; do
		start=`date +%s%N`
		end=$($CMD -it --runtime=crun --rm -e TZ=$timezone postgres:11.1 /bin/bash -c 'date +%s%N')
		echo $start","$end >> $POSTGRES_CRUN_LOG
		SLEEP_BETWEEN
	done

	rm $ALPINE_CRUN_LOG
	for i in `seq 1 $ITERATIONS`; do
		start=`date +%s%N`
		# https://stackoverflow.com/a/38872276
		end=$($CMD -it --runtime=crun --rm -e TZ=$timezone alpine:3.14.1 /bin/sh -c "adjtimex | awk '/(time.tv_sec|time.tv_usec):/ { printf(\"%06d\", \$2) }'")
		echo $start","$end >> $ALPINE_CRUN_LOG
		SLEEP_BETWEEN
	done
	
else 
	echo "Second has to be either crun or runc"
	exit 1
fi
