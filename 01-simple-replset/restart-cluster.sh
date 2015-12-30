#!/bin/bash

# Test if there is instances running
kill $(ps aux | grep mongodb.conf | grep config | awk '{print $2}')

cd rs1
mongod --config mongodb.conf --fork

cd ../rs2
mongod --config mongodb.conf --fork

cd ../rs3
mongod --config mongodb.conf --fork