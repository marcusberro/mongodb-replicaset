#!/bin/bash

mkdir rs1/db
mkdir rs2/db
mkdir rs3/db

cd rs1
mongod --config mongodb.conf --fork

cd ../rs2
mongod --config mongodb.conf --fork

cd ../rs3
mongod --config mongodb.conf --fork