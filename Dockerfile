FROM ubuntu:18.04
MAINTAINER hidetomo

ENV DEBIAN_FRONTEND noninteractive

# create user
COPY files/root_pass root_pass
RUN echo "root:$(cat root_pass)" | chpasswd && \
  useradd hidetomo && \
  mkdir /home/hidetomo && \
  chown hidetomo:hidetomo /home/hidetomo
COPY files/hidetomo_pass hidetomo_pass
RUN echo "hidetomo:$(cat hidetomo_pass)" | chpasswd

# sudo
RUN apt -y update && \
  apt -y install sudo && \
  echo "hidetomo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# change user and dir
USER hidetomo
WORKDIR /home/hidetomo
ENV HOME /home/hidetomo

# wget
RUN sudo apt -y update && \
  sudo apt -y install wget

# alias
RUN wget https://raw.githubusercontent.com/hidetomo-watanabe/dotfiles/master/.git-prompt.sh
RUN wget https://raw.githubusercontent.com/hidetomo-watanabe/dotfiles/master/.bash_profile
RUN chmod 600 .bash_profile
RUN echo "source ~/.bash_profile" >> .bashrc

# vim
RUN sudo apt -y update && \
  sudo apt -y install vim
RUN wget https://raw.githubusercontent.com/hidetomo-watanabe/dotfiles/master/vimrc_simple -O .vimrc
RUN sudo tr \\r \\n <.vimrc> tmp && sudo mv tmp .vimrc && \
  sudo chown hidetomo:hidetomo .vimrc

# share
RUN mkdir share
VOLUME share

# tzdata
RUN sudo apt -y update && \
  sudo apt -y install \
    tzdata
ENV TZ Asia/Tokyo

# common apt
RUN sudo apt -y update && \
  sudo apt -y install \
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
    curl \
    nkf \
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
  pip install opencv-python==4.1.2.30 \
    memory_profiler==0.55.0 \
    flake8==3.7.9 \
    flake8-import-order==0.18.1 \
    tqdm==4.40.0 \
    pandas-profiling==2.3.0 \
    Cython==0.29.14 \
    schema==0.7.1 \
    dask==2.9.0 \
    scikit-learn==0.21.3 \
    category-encoders==2.1.0 \
    imbalanced-learn==0.5.0 \
    eli5==0.10.1 \
    boruta==0.3 \
    heamy==0.0.7 \
    kaggle==1.5.6

# version down for shap
RUN pip install scikit-image==0.14.2

# jupyter
RUN pip install jupyter==1.0.0 \
  jupyter-contrib-nbextensions==0.5.1 \
  jupyterthemes==0.20.0
RUN jupyter-notebook --generate-config && \
  echo 'c.NotebookApp.ip = "0.0.0.0"' >> .jupyter/jupyter_notebook_config.py && \
  echo 'c.NotebookApp.open_browser = False' >> .jupyter/jupyter_notebook_config.py
RUN jt -t monokai -T -N -kl -f inconsolata -tfs 11 -cellw 90% && \
  jupyter nbextension enable --py --sys-prefix widgetsnbextension
RUN mkdir -p $(jupyter --data-dir)/nbextensions && \
  cd $(jupyter --data-dir)/nbextensions && \
  git clone https://github.com/lambdalisue/jupyter-vim-binding vim_binding && \
  jupyter nbextension enable vim_binding/vim_binding
RUN cd .jupyter/custom && \
  echo '/* Jupyter cell is in normal mode when code mirror */' >> tmp_custom.css && \
  echo '.edit_mode .cell.selected .CodeMirror-focused.cm-fat-cursor {' >> tmp_custom.css && \
  echo ' background-color: #000000 !important;' >> tmp_custom.css && \
  echo '}' >> tmp_custom.css && \
  echo '/* Jupyter cell is in insert mode when code mirror */' >> tmp_custom.css && \
  echo '.edit_mode .cell.selected .CodeMirror-focused:not(.cm-fat-cursor) {' >> tmp_custom.css && \
  echo ' background-color: #000000 !important;' >> tmp_custom.css && \
  echo '}' >> tmp_custom.css && \
  cat custom.css >> tmp_custom.css && \
  mv tmp_custom.css custom.css

# optuna
RUN pip install optuna==0.19.0

# nlp
RUN pip install python-Levenshtein==0.12.0 \
  zenhan==0.5.2 \
  pykakasi==1.2 \
  nltk==3.4.5 \
  spacy==2.2.3 \
  gensim==3.8.1 \
  fasttext==0.9.1

# mecab
RUN sudo apt -y update && \
  sudo apt -y install \
    swig \
    mecab \
    libmecab-dev \
    mecab-ipadic \
    mecab-ipadic-utf8
RUN pip install mecab-python3==0.996.2

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
# RUN sudo apt -y update && \
  # sudo apt -y install openjdk-7-jdk && \
  # curl -L -O http://nlp.stanford.edu/software/stanford-corenlp-full-2013-06-20.zip && \
  # sudo unzip ./stanford-corenlp-full-2013-06-20.zip -d /usr/local/lib/ && \
  # rm ./stanford-corenlp-full-2013-06-20.zip && \
  # pip install corenlp-python==3.4.1.post1

# ocr
RUN sudo apt -y update && \
  sudo apt -y install \
    tesseract-ocr \
    libtesseract-dev
RUN pip install pyocr==0.7.2

# xgboost
RUN pip install xgboost==0.90

# lightgbm
RUN pip install lightgbm==2.3.1

# catboost
RUN pip install catboost==0.20.1

# rgf
RUN pip install rgf-python==3.6.0

# keras
RUN pip install tensorflow==2.0.0 \
  Keras==2.3.1

# pytorch
RUN pip install torch==1.3.1 \
  torchvision==0.4.2 \
  skorch==0.7.0

# bert
RUN git clone -b master https://github.com/charles9n/bert-sklearn && \
  cd bert-sklearn/ && \
  pip install .

# graphviz
RUN sudo apt -y update && \
  sudo apt -y install graphviz && \
  pip install graphviz==0.13.2

# seaborn
RUN pip install seaborn==0.9.0

# dtreeviz
RUN sudo apt -y update && \
  sudo apt -y install xdg-utils && \
  pip install dtreeviz==0.8.1

# shap
RUN pip install shap==0.33.0

# start
CMD ["jupyter", "notebook", "--notebook-dir=share", "--port=8888"]
