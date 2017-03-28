#!/bin/bash

export LC_ALL=C; /usr/bin/mongod --dbpath mongo/db > mongo/log 2>&1 &
