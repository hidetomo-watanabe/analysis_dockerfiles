# analysis_dockerfiles

### docker command for cpu
- cp docker-compose.yml docker-compose.override.yml
- vi docker-compose.override.yml
- docker-compose up -d

### docker command for gpu
- docker build -t mlenv_gpu -f Dockerfile_gpu .
- docker run --name mlenv_gpu --hostname mlenv_gpu --gpus all --net='host' -v $(pwd)/share:/home/hidetomo/share -v $(pwd)/.ssh:/home/hidetomo/.ssh --privileged=true --restart=always -itd mlenv_gpu

### memo
- もし`Fatal Python error: _Py_HashRandomization_Init: failed to get random numbers to initialize Python`が発生したら、以下を実行
  - Dockerfileの`create hidetomo`をコメントアウト
  - コンテナ起動設定の`/home/hidetomo`を`/root`に変更

### ref
- https://github.com/hidetomo-watanabe/sklearn_wrapper
