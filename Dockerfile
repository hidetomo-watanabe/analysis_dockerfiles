FROM ubuntu:14.04
MAINTAINER hidetomo

# create user
COPY files/root_pass root_pass
RUN echo "root:$(cat root_pass)" | chpasswd && \
  useradd hidetomo && \
  mkdir /home/hidetomo && \
  chown hidetomo:hidetomo /home/hidetomo
COPY files/hidetomo_pass hidetomo_pass
RUN echo "hidetomo:$(cat hidetomo_pass)" | chpasswd

# sudo
RUN apt-get -y update && \
  apt-get -y install sudo && \
  echo "hidetomo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# change user and dir
USER hidetomo
WORKDIR /home/hidetomo
ENV HOME /home/hidetomo

# alias
RUN echo "alias ls='ls --color'" >> .bashrc && \
  echo "alias ll='ls -lat'" >> .bashrc

# vim
RUN sudo apt-get -y update && \
  sudo apt-get -y install vim
COPY files/.vimrc .vimrc
RUN sudo tr \\r \\n <.vimrc> tmp && sudo mv tmp .vimrc && \
  sudo chown hidetomo:hidetomo .vimrc

# share
RUN mkdir share
VOLUME share

# common apt-get
RUN sudo apt-get -y update && \
  sudo apt-get -y install \
    ntp \
    htop \
    less \
    zip \
    unzip \
    bzip2 \
    gcc \
    g++ \
    cmake \
    git \
    subversion \
    wget \
    curl \
    nkf \
    fglrx \
    language-pack-ja-base \
    language-pack-ja \
    xvfb \
    xfonts-100dpi \
    xfonts-75dpi \
    xfonts-scalable \
    xfonts-cyrillic \
    fonts-takao-*

# LC
RUN echo "export LC_ALL=ja_JP.UTF-8" >> .bashrc
ENV LC_ALL ja_JP.UTF-8

# pyenv
RUN git clone https://github.com/yyuu/pyenv.git .pyenv && \
  echo 'export PYENV_ROOT="$HOME/.pyenv"' >> .bashrc
ENV PYENV_ROOT $HOME/.pyenv
RUN echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> .bashrc && \
  echo 'eval "$(pyenv init -)"' >> .bashrc && \
  echo 'export PYTHONIOENCODING=utf-8' >> .bashrc
ENV PATH $PYENV_ROOT/bin:$PATH

# anaconda
ARG pyVer=miniconda3-4.3.30
RUN pyenv install ${pyVer} && \
  pyenv rehash && \
  pyenv global ${pyVer} && \
  echo 'export PATH="$PYENV_ROOT/versions/'${pyVer}'/bin/:$PATH"' >> .bashrc
ENV PATH $PYENV_ROOT/versions/${pyVer}/bin/:$PATH

# common conda or pip
RUN conda install -y pip && \
  conda install -y openCV && \
  conda install -y scikit-learn && \
  conda install -y dask && \
  conda install -y flake8 && \
  conda install -y tqdm && \
  pip install memory_profiler && \
  pip install Cython && \
  pip install schema && \
  pip install pandas-profiling && \
  pip install shap && \
  pip install imbalanced-learn && \
  pip install eli5 && \
  pip install heamy && \
  pip install kaggle

# version down for shap
RUN pip install scikit-image==0.14.2

# jupyter
RUN conda install -y jupyter
RUN jupyter-notebook --generate-config && \
  echo 'c.NotebookApp.ip = "0.0.0.0"' >> .jupyter/jupyter_notebook_config.py && \
  echo 'c.NotebookApp.open_browser = False' >> .jupyter/jupyter_notebook_config.py && \
  echo 'c.NotebookApp.port = 8888' >> .jupyter/jupyter_notebook_config.py && \
  pip install jupyterthemes && \
  jt -t grade3 -f hack && \
  jupyter nbextension enable --py --sys-prefix widgetsnbextension
EXPOSE 8888

# optuna
RUN pip install optuna

# nlp
RUN pip install python-Levenshtein && \
  pip install zenhan && \
  pip install pykakasi && \
  pip install nltk && \
  pip install spacy && \
  pip install gensim && \
  pip install fasttext

# mecab
RUN sudo apt-get -y update && \
  sudo apt-get -y install \
    swig \
    mecab \
    libmecab-dev \
    mecab-ipadic \
    mecab-ipadic-utf8
RUN pip install mecab-python3

# cabocha
COPY files/CRF++-0.58.tar.gz .
RUN tar zxvf CRF++-0.58.tar.gz && \
  rm CRF++-0.58.tar.gz && \
  cd CRF++-0.58 && \
  ./configure && \
  make && \
  sudo make install
USER root
RUN echo "include /usr/local/bin" >> /etc/ld.so.conf && \
  ldconfig
USER hidetomo
COPY files/cabocha-0.69.tar.bz2 .
RUN bzip2 -dc cabocha-0.69.tar.bz2 | tar xvf - && \
  rm cabocha-0.69.tar.bz2 && \
  cd cabocha-0.69 && \
  ./configure --with-charset=UTF8 --enable-utf8-only && \
  make && \
  sudo make install
RUN cd cabocha-0.69 && \
  cd python && \
  python setup.py build_ext && \
  python setup.py install && \
  sudo ldconfig

# stanford-corenlp
RUN sudo apt-get -y update && \
  sudo apt-get -y install openjdk-7-jdk && \
  curl -L -O http://nlp.stanford.edu/software/stanford-corenlp-full-2013-06-20.zip && \
  sudo unzip ./stanford-corenlp-full-2013-06-20.zip -d /usr/local/lib/ && \
  rm ./stanford-corenlp-full-2013-06-20.zip && \
  pip install corenlp-python

# bert
RUN pip install keras-bert

# ocr
RUN sudo apt-get -y update && \
  sudo apt-get -y install \
    tesseract-ocr \
    libtesseract-dev
RUN pip install pyocr

# opencv
RUN pip install opencv-python

# xgboost
RUN git clone --recursive https://github.com/dmlc/xgboost && \
  cd xgboost && \
  make -j4 && \
  cd python-package && \
  python -u setup.py install

# lightgbm
RUN git clone --recursive https://github.com/Microsoft/LightGBM.git && \
  cd LightGBM && \
  cd python-package && \
  python -u setup.py install

# catboost
RUN pip install catboost

# rgf
RUN pip install rgf-python

# keras
RUN pip install tensorflow && \
  pip install keras

# seaborn
RUN conda install -y seaborn

# graphviz
RUN sudo apt-get -y update && \
  sudo apt-get -y install graphviz && \
  conda install -y graphviz

# preinstall
COPY files/start.sh start.sh
RUN sudo tr \\r \\n <start.sh> tmp && sudo mv tmp start.sh && \
  sudo chown hidetomo:hidetomo start.sh && \
  chmod 644 start.sh

# start
CMD ["/bin/bash", "./start.sh"]
