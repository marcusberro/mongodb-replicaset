#!/bin/bash

echo " "
echo " ### Starting replica set cluster..."

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