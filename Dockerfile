FROM centos:7
MAINTAINER hidetomo

# version
ARG pyVer=anaconda3-4.0.0
ARG pipVer=8.1.2
ARG openCVVer=3.1.0
ARG schemaVer=0.5.0
ARG flake8Ver=2.6.2
ARG seabornVer=0.7.1
ARG malssVer=v1.0.0

# create user
COPY root_pass root_pass
RUN echo "root:$(cat root_pass)" | chpasswd
RUN useradd hidetomo
COPY hidetomo_pass hidetomo_pass
RUN echo "hidetomo:$(cat hidetomo_pass)" | chpasswd

# init yum
RUN yum -y update
RUN yum -y install initscripts

# sudo
RUN yum -y install sudo
RUN echo "hidetomo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# change user and dir
USER hidetomo
WORKDIR /home/hidetomo
ENV HOME /home/hidetomo

# ssh key
COPY id_rsa .ssh/id_rsa
RUN sudo tr \\r \\n <.ssh/id_rsa> tmp && sudo mv tmp .ssh/id_rsa
RUN sudo chown hidetomo:hidetomo .ssh/id_rsa
RUN chmod 600 .ssh/id_rsa

# ssh known hosts
RUN sudo touch .ssh/known_hosts
RUN sudo chown hidetomo:hidetomo .ssh/known_hosts
RUN chmod 644 .ssh/known_hosts

# vim
RUN sudo yum -y install vim
COPY vimrc_simple .vimrc
RUN sudo tr \\r \\n <.vimrc> tmp && sudo mv tmp .vimrc
RUN sudo chown hidetomo:hidetomo .vimrc

# share
RUN mkdir share
VOLUME share

# common yum
RUN sudo yum -y install \
  bzip2 \
  gcc \
  git \
  less \
  svn \
  wget

# git config
RUN git config --global user.email 'hidetomo.watanabe@soinn.com'
RUN git config --global user.name 'hidetomo.watanabe'

# pyenv
RUN git clone https://github.com/yyuu/pyenv.git .pyenv
RUN echo 'export PYENV_ROOT="$HOME/.pyenv"' >> .bashrc
ENV PYENV_ROOT $HOME/.pyenv
RUN echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> .bashrc
ENV PATH $PYENV_ROOT/bin:$PATH
RUN echo 'eval "$(pyenv init -)"' >> .bashrc

# anaconda
# RUN pyenv install -l | grep ana
RUN pyenv install ${pyVer}
RUN pyenv rehash
RUN pyenv global ${pyVer}
RUN echo 'export PATH="$PYENV_ROOT/versions/'${pyVer}'/bin/:$PATH"' >> .bashrc
ENV PATH $PYENV_ROOT/versions/${pyVer}/bin/:$PATH

# common conda or pip
RUN conda install -y pip=${pipVer}
RUN conda install -y openCV=${openCVVer}
RUN pip install schema==${schemaVer}
RUN pip install flake8==${flake8Ver}
RUN conda install -y seaborn=${seabornVer}

# mongo
COPY mongodb.repo /etc/yum.repos.d/mongodb.repo
RUN sudo tr \\r \\n </etc/yum.repos.d/mongodb.repo> tmp && sudo mv tmp /etc/yum.repos.d/mongodb.repo
RUN sudo yum -y install mongodb-org
RUN mkdir mongo
RUN mkdir mongo/db
RUN echo "export LC_ALL=C" >> .bashrc
ENV LC_ALL C
RUN conda install -y pymongo

# graphviz
RUN sudo yum -y install graphviz
RUN conda install -y graphviz
RUN pip install graphviz

# malss
RUN pip install malss==${malssVer}

# keras
RUN pip install tensorFlow
RUN pip install keras

# preinstall
RUN mkdir works
COPY start.sh start.sh
RUN sudo tr \\r \\n <start.sh> tmp && sudo mv tmp start.sh
RUN sudo chown hidetomo:hidetomo start.sh
RUN chmod 644 start.sh
COPY install_sdk.sh install_sdk.sh
RUN sudo tr \\r \\n <install_sdk.sh> tmp && sudo mv tmp install_sdk.sh
RUN sudo chown hidetomo:hidetomo install_sdk.sh
RUN chmod 644 install_sdk.sh

# start
CMD ["/bin/bash", "./start.sh"]
