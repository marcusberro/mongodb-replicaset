#!/bin/bash

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
echo " ### Purge replica set dbs"

rm -rf rs1/db
rm -rf rs2/db
rm -rf rs3/db