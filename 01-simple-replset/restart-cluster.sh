#!/usr/bin/env bash

scriptPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Stop replica set

PIDS_MONGO=`ps aux | grep mongodb.conf | grep config | awk '{print $2}'`

if [ -z "$PIDS_MONGO" ]; then
	echo " ### Mongo replica set nodes are not running"
else
	echo " ### Stoping mongo instances"
	for PID in $PIDS_MONGO; do
		echo "Killing mongo process: $PID"
		kill $PID
	done 
fi

echo " "
echo " ### Starting replica set: rs1"
cd ${scriptPath}/rs1
mongod --config mongodb.conf --fork

echo " "
echo " ### Starting replica set: rs2"
cd ${scriptPath}/rs2
mongod --config mongodb.conf --fork

echo " "
echo " ### Starting replica set: rs3"
cd ${scriptPath}/rs3
mongod --config mongodb.conf --fork

echo " "