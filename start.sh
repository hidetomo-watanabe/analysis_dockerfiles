#!/bin/bash

cd /home/hidetomo
source ~/.bashrc
/usr/bin/mongod --dbpath mongo/db > mongo/log 2>&1 &

while true; do
  sleep 10
done