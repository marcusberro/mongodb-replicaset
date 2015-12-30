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

mkdir rs1/db
mkdir rs2/db
mkdir rs3/db

echo " "
echo " ### Starting replica set: rs1"
cd rs1
mongod --config mongodb.conf --fork

echo " "
echo " ### Starting replica set: rs2"
cd ../rs2
mongod --config mongodb.conf --fork

echo " "
echo " ### Starting replica set: rs3"
cd ../rs3
mongod --config mongodb.conf --fork

echo " "