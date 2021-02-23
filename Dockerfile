FROM gcr.io/kaggle-images/python:v95
MAINTAINER hidetomo

# change build dir
WORKDIR /root
ENV HOME /root

# tzdata
RUN apt -y update && \
  apt -y install \
    tzdata
ENV TZ Asia/Tokyo

# common apt
RUN apt -y update && \
  apt -y install \
    sudo \
    htop \
    nkf

# common pip
RUN pip install \
  flake8-import-order==0.18.1 \
  fire==0.4.0 \
  heamy==0.0.7

# nlp
RUN pip install \
  zenhan==0.5.2 \
  pykakasi==2.0.4

# mecab
RUN apt -y update && \
  apt -y install \
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
  make install
RUN echo "include /usr/local/bin" >> /etc/ld.so.conf && \
  ldconfig
COPY files/cabocha-0.69.tar.bz2 .
RUN bzip2 -dc cabocha-0.69.tar.bz2 | tar xvf - && \
  rm cabocha-0.69.tar.bz2 && \
  cd cabocha-0.69 && \
  ./configure --with-charset=UTF8 --enable-utf8-only && \
  make && \
  make install
RUN cd cabocha-0.69 && \
  cd python && \
  python setup.py build_ext && \
  python setup.py install && \
  ldconfig

# torch
RUN pip install \
  skorch==0.9.0

# bert
RUN pip install \
  bert-for-tf2==0.14.9

# dtreeviz
RUN apt -y update && \
  apt -y install xdg-utils && \
  pip install dtreeviz==0.8.1

# japanize
RUN pip install japanize-matplotlib==1.1.2

# jupyter
RUN pip install \
  jupyter-contrib-nbextensions==0.5.1 \
  jupyterthemes==0.20.0
RUN mkdir -p $(jupyter --data-dir)/nbextensions && \
  cd $(jupyter --data-dir)/nbextensions && \
  git clone https://github.com/lambdalisue/jupyter-vim-binding vim_binding && \
  jupyter nbextension enable vim_binding/vim_binding
RUN jupyter nbextension enable --py --sys-prefix widgetsnbextension

# create work user
RUN useradd hidetomo && \
  mkdir /home/hidetomo && \
  chown hidetomo:hidetomo /home/hidetomo && \
  echo "hidetomo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER hidetomo
WORKDIR /home/hidetomo
ENV HOME /home/hidetomo
ENV PATH /opt/conda/bin:$PATH

# share
RUN mkdir share
VOLUME share

# bash
RUN wget https://raw.githubusercontent.com/hidetomo-watanabe/dotfiles/master/bash/.git-prompt.sh
RUN wget https://raw.githubusercontent.com/hidetomo-watanabe/dotfiles/master/bash/.bash_profile
RUN chmod 600 .bash_profile
RUN echo "source ~/.bash_profile" >> .bashrc

# vim
RUN wget https://raw.githubusercontent.com/hidetomo-watanabe/dotfiles/master/vimrc_simple -O .vimrc
RUN tr \\r \\n <.vimrc> vimrc_tmp && mv vimrc_tmp .vimrc

# jupyter customize
RUN jt -t monokai -T -N -kl -f inconsolata -tfs 11 -cellw 90% && \
  cd .jupyter/custom && \
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
RUN jupyter-notebook --generate-config && \
  echo 'c.NotebookApp.ip = "0.0.0.0"' >> .jupyter/jupyter_notebook_config.py && \
  echo 'c.NotebookApp.open_browser = False' >> .jupyter/jupyter_notebook_config.py && \
  echo 'c.NotebookApp.browser = "chrome"' >> .jupyter/jupyter_notebook_config.py

# start
CMD ["jupyter", "notebook", "--notebook-dir=share", "--port=8888"]
