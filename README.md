# dev_by_docker

### docker machine command
- docker-machine rm default
- docker-machine create default --driver virtualbox --virtualbox-disk-size 60000 --virtualbox-memory 16384 --virtualbox-cpu-count 4
- docker-machine ssh

### docker command
- **cpは適時対応**
- cd Dockerfiles
- sh create/XX.sh > Dockerfile
- (nvidia-)docker build -t hidetomo_dev dev_by_docker
- docker-compose up -d
  - nvidia-dockerは非対応
- docker exec -it hidetomo_dev /bin/bash
- docker-compose stop
- docker-compose rm
