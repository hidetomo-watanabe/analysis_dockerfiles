FROM centos:7
MAINTAINER hidetomo

# create user
RUN echo "root:root" | chpasswd
RUN useradd hidetomo
RUN echo "hidetomo:hogehoge" | chpasswd

# init yum
RUN yum -y update
RUN yum -y install initscripts

# sudo
RUN yum -y install sudo
RUN echo "hidetomo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# ssh
RUN yum -y install openssh-server openssh-clients
RUN echo "PermitRootLogin no" >> /etc/ssh/sshd_config
RUN sed -i -e 's/^PasswordAuthentication yes$/PasswordAuthentication no/g' /etc/ssh/sshd_config
# RUN sed -i -e '/^HostKey/s/^/# /g' /etc/ssh/sshd_config
RUN ssh-keygen -t rsa -N "" -f /etc/ssh/ssh_host_rsa_key
RUN ssh-keygen -t rsa -N "" -f /etc/ssh/ssh_host_ecdsa_key
RUN ssh-keygen -t rsa -N "" -f /etc/ssh/ssh_host_ed25519_key

# change user and dir
USER hidetomo
WORKDIR /home/hidetomo

# authorized keys
RUN mkdir -p .ssh
COPY authorized_keys .ssh/authorized_keys
RUN sudo chown hidetomo:hidetomo .ssh/authorized_keys
RUN chmod 700 .ssh
RUN chmod 600 .ssh/authorized_keys
EXPOSE 22

# ssh key
COPY id_rsa .ssh/id_rsa
RUN sudo chown hidetomo:hidetomo .ssh/id_rsa

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
# CMD ["sudo systemctl start mongod"]
RUN echo "export LC_ALL=C" >> .bashrc

# preinstall
# RUN sudo yum -y install anaconda
RUN wget -O /home/hidetomo/Anaconda3.sh https://repo.continuum.io/archive/Anaconda3-4.2.0-Linux-x86_64.sh
RUN sudo yum -y install graphviz
RUN mkdir works
COPY start.sh start.sh
RUN sudo chown hidetomo:hidetomo start.sh
COPY install_base.sh install_base.sh
RUN sudo chown hidetomo:hidetomo install_base.sh
COPY install_sdk.sh install_sdk.sh
RUN sudo chown hidetomo:hidetomo install_sdk.sh

# change user and dir
USER root
WORKDIR /root

# start
# CMD ["sudo systemctl start sshd.service"]
CMD ["/usr/sbin/sshd", "-D"]
