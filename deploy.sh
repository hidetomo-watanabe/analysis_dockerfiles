#!/bin/bash

MODE=$1

# COPY
if [ ! -e docker-compose.yml ]; then
  echo "[WARN] NO docker-compose.yml"
  echo "[WARN] COPY docker-compose.yml.org"
  cp docker-compose.yml.org docker-compose.yml
fi

# MAIN
cd Dockerfiles
sh ./create/mlenv.sh > ../Dockerfile
cd ../
docker build -t mlenv .
docker-compose stop
docker-compose rm -f
docker-compose up -d