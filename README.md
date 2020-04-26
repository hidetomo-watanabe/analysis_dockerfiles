# analysis_dockerfiles

### docker command for cpu
- cp docker-compose.yml.org docker-compose.yml
- docker-compose up -d

### docker command for gpu
- docker build -t mlenv_gpu -f Dockerfile_gpu .
- docker run --name mlenv_gpu --gpus all --net='host' -v $(pwd)/share:/home/hidetomo/share -v $(pwd)/.ssh:/home/hidetomo/.ssh --privileged=true --restart=always -itd mlenv_gpu

### ref
- https://github.com/hidetomo-watanabe/analysis_for_kaggle
