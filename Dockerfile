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

# ssh key
COPY id_rsa .ssh/id_rsa
RUN sudo chown hidetomo:hidetomo .ssh/id_rsa
RUN chmod 600 .ssh/id_rsa

# vim
RUN sudo yum -y install vim
COPY vimrc_simple .vimrc
RUN sudo chown hidetomo:hidetomo .vimrc

# share
RUN mkdir share
VOLUME share

# common yum
RUN sudo yum -y install less wget bzip2 gcc git svn

# mongo
COPY mongodb.repo /etc/yum.repos.d/mongodb.repo
RUN sudo yum -y install mongodb-org
RUN mkdir mongo
RUN mkdir mongo/db
RUN echo "export LC_ALL=C" >> .bashrc

# preinstall
# RUN sudo yum -y install anaconda
RUN wget -O /home/hidetomo/Anaconda3.sh https://repo.continuum.io/archive/Anaconda3-4.2.0-Linux-x86_64.sh
RUN sudo yum -y install graphviz
RUN mkdir works
COPY start.sh start.sh
RUN sudo chown hidetomo:hidetomo start.sh
RUN chmod 644 start.sh
COPY install_base.sh install_base.sh
RUN sudo chown hidetomo:hidetomo install_base.sh
RUN chmod 644 install_base.sh
COPY install_sdk.sh install_sdk.sh
RUN sudo chown hidetomo:hidetomo install_sdk.sh
RUN chmod 644 install_sdk.sh

# start
CMD ["/bin/bash", "./start.sh"]
