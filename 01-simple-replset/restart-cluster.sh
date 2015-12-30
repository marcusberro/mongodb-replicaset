#!/bin/bash

# Stop replica set

PIDS_MONGO=`ps aux | grep mongodb.conf | grep config | awk '{print $2}'`

if [ -z "$PIDS_MONGO" ]; then
	echo "Mongo replica set nodes are not running"
else
	echo "Stoping mongo instances"
	for PID in $PIDS_MONGO; do
		echo "Killing mongo process: $PID"
		kill $PID
	done 
fi

cd rs1
mongod --config mongodb.conf --fork

cd ../rs2
mongod --config mongodb.conf --fork

cd ../rs3
mongod --config mongodb.conf --fork