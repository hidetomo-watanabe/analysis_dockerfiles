# dev_by_docker

### docker machine command
- docker-machine rm default
- docker-machine create default --driver virtualbox --virtualbox-disk-size 60000 --virtualbox-memory 16384 --virtualbox-cpu-count 4
- docker-machine ssh

### docker command
- docker build -t hidetomo_dev dev_by_docker
- docker run -itd --privileged --name hidetomo_dev --hostname hidetomo_dev -v /host/path:/home/hidetomo/share hidetomo_dev
- docker exec -it hidetomo_dev sudo su - hidetomo

### centos command
- sh ./install_base.sh
- sh ./install_sdk.sh
