# dev_by_docker

### docker command
- docker build -t hidetomo_dev dev_by_docker
- docker run -itd --privileged -p 2222:22 --name hidetomo_dev --hostname hidetomo_dev -v /host/path:/home/hidetomo/share hidetomo_dev

### centos command
- sh ./install_base.sh
- sh ./install_sdk.sh
