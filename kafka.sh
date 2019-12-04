#!/bin/bash
#
# Script to start & stop the kafka server within the container
#

readonly CHECK_INTERVAL_SEC=3
readonly MAX_CHECK_COUNT=10

function stop_kafka
{
        trap - SIGINT SIGTERM
	echo "Stopping kafka server..."
	bin/kafka-server-stop.sh
	echo "Stopping zookeeper server..."
	bin/zookeeper-server-stop.sh 
        kill -- -$$
        exit 0
}

function start_kafka
{
	echo "Starting kafka server..."
	cd /kafka
	bin/zookeeper-server-start.sh config/zookeeper.properties &
	for checkCount in $(seq 1 ${MAX_CHECK_COUNT}); do
		echo "Wating ${CHECK_INTERVAL_SEC} seconds for zookeer server to start..."
		sleep ${CHECK_INTERVAL_SEC}
		PIDS=$(ps ax | grep java | grep -i QuorumPeerMain | grep -v grep | awk '{print $1}')
		if [ ! -z "$PIDS" ]; then
			echo "Zookeeper server started"
			break
		fi
	done 
	if [ -z "$PIDS" ]; then
		echo "Zookeeper server did not start within the alloted time. Not starting Kafka server. aborting..."
		exit 1
	else
		bin/kafka-server-start.sh config/server.properties &
		for checkCount in $(seq 1 ${MAX_CHECK_COUNT}); do
			echo "Waiting ${CHECK_INTERVAL_SEC} seconds for kafka server to start..."
			sleep ${CHECK_INTERVAL_SEC}
  			PIDS=$(ps ax | grep -i 'kafka\.Kafka' | grep java | grep -v grep | awk '{print $1}')
			if [ ! -z "$PIDS" ]; then
				echo "Kafka server started."
				break
			fi
		done
		if [ -z "$PIDS" ]; then
			echo "Kafka server failed to start within alloted time.  Aborting..."
			echo "Stopping zookeeper server..."
			bin/zookeeper-server-stop.sh 
			exit 1
		fi
	fi
}

start_kafka
trap - SIGINT SIGTERM
trap 'stop_kafka' SIGINT SIGTERM
sleep infinity &
wait $!

#::END::
