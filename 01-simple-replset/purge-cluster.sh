#!/bin/bash

# Test if there is instances running
kill $(ps aux | grep mongodb.conf | grep config | awk '{print $2}')

rm -rf rs1/db
rm -rf rs2/db
rm -rf rs3/db