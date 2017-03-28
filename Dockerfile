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

# change user
RUN su - hidetomo

# ssh
RUN sudo yum -y install openssh-server openssh-clients
RUN sudo echo "RSAAuthentication yes" >> /etc/ssh/sshd_config
RUN sudo echo "PubKeyAuthentication yes" >> /etc/ssh/sshd_config
# RUN sed -i -e '/^HostKey/s/^/# /g' /etc/ssh/sshd_config
RUN ssh-keygen -t rsa -N "" -f /etc/ssh/ssh_host_rsa_key
RUN ssh-keygen -t rsa -N "" -f /etc/ssh/ssh_host_ecdsa_key
RUN ssh-keygen -t rsa -N "" -f /etc/ssh/ssh_host_ed25519_key
RUN mkdir -p /home/hidetomo/.ssh
RUN chown hidetomo /home/hidetomo/.ssh
RUN chmod 700 /home/hidetomo/.ssh
ADD authorized_keys /home/hidetomo/.ssh/authorized_keys
RUN chown hidetomo /home/hidetomo/.ssh/authorized_keys
RUN chmod 600 /home/hidetomo/.ssh/authorized_keys
EXPOSE 22

# ssh key
ADD id_rsa /home/hidetomo/.ssh/id_rsa
RUN chown hidetomo:hidetomo /home/hidetomo/.ssh/id_rsa

# vim
RUN sudo yum -y install vim
ADD vimrc_simple /home/hidetomo/.vimrc

# share
RUN mkdir /home/hidetomo/share
VOLUME /home/hidetomo/share

# common yum
RUN sudo yum -y install less wget bzip2 gcc git svn

# mongo
ADD mongodb.repo /etc/yum.repos.d/mongodb.repo
RUN sudo yum -y install mongodb-org
RUN mkdir /home/hidetomo/mongo
RUN chown hidetomo:hidetomo /home/hidetomo/mongo
RUN mkdir /home/hidetomo/mongo/db
RUN chown hidetomo:hidetomo /home/hidetomo/mongo/db

# preinstall
# RUN sudo yum -y install anaconda
RUN cd /home/hidetomo
RUN wget -O /home/hidetomo/Anaconda3.sh https://repo.continuum.io/archive/Anaconda3-4.2.0-Linux-x86_64.sh
RUN sudo yum -y install graphviz
RUN mkdir /home/hidetomo/works
RUN chown hidetomo:hidetomo /home/hidetomo/works
ADD install_base.sh /home/hidetomo/install_base.sh
ADD install_sdk.sh /home/hidetomo/install_sdk.sh

# start
CMD ["sudo /sbin/init"]
# CMD ["sudo systemctl start mongod"]
# CMD ["sudo systemctl start sshd.service"]
CMD ["export LC_ALL=C"]
CMD ["/usr/bin/mongod --dbpath /home/hidetomo/mongo/db > /home/hidetomo/mongo/log 2>&1", "-D"]
CMD ["/usr/sbin/sshd", "-D"]
