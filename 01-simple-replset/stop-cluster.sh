#!/bin/bash

# Test if there is instances running
kill $(ps aux | grep mongodb.conf | grep config | awk '{print $2}')