FROM centos:7
MAINTAINER hidetomo

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
RUN tr \\r \\n <.ssh/id_rsa> tmp && mv tmp .ssh/id_rsa
RUN sudo chown hidetomo:hidetomo .ssh/id_rsa
RUN chmod 600 .ssh/id_rsa

# vim
RUN sudo yum -y install vim
COPY vimrc_simple .vimrc
RUN tr \\r \\n <.vimrc> tmp && mv tmp .vimrc
RUN sudo chown hidetomo:hidetomo .vimrc

# share
RUN mkdir share
VOLUME share

# common yum
RUN sudo yum -y install less wget bzip2 gcc git svn

# pyenv
RUN git clone https://github.com/yyuu/pyenv.git .pyenv
RUN echo 'export PYENV_ROOT="$HOME/.pyenv"' >> .bashrc
ENV PYENV_ROOT $HOME/.pyenv
RUN echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> .bashrc
ENV PATH $PYENV_ROOT/bin:$PATH
RUN echo 'eval "$(pyenv init -)"' >> .bashrc

# anaconda
# RUN pyenv install -l | grep ana
RUN pyenv install anaconda3-4.3.1
RUN pyenv rehash
RUN pyenv global anaconda3-4.3.1
RUN echo 'export PATH="$PYENV_ROOT/versions/anaconda3-4.3.1/bin/:$PATH"' >> .bashrc
ENV PATH $PYENV_ROOT/versions/anaconda3-4.3.1/bin/:$PATH
RUN conda update -y conda
RUN conda update -y anaconda
RUN conda update -y --all

# mongo
COPY mongodb.repo /etc/yum.repos.d/mongodb.repo
RUN tr \\r \\n </etc/yum.repos.d/mongodb.repo> tmp && mv tmp /etc/yum.repos.d/mongodb.repo
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

# preinstall
RUN mkdir works
COPY start.sh start.sh
RUN tr \\r \\n <start.sh> tmp && mv tmp start.sh
RUN sudo chown hidetomo:hidetomo start.sh
RUN chmod 644 start.sh
COPY install_sdk.sh install_sdk.sh
RUN tr \\r \\n <install_sdk.sh> tmp && mv tmp install_sdk.sh
RUN sudo chown hidetomo:hidetomo install_sdk.sh
RUN chmod 644 install_sdk.sh

# start
CMD ["/bin/bash", "./start.sh"]
