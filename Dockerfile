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

# vim
RUN sudo yum -y install vim
ADD vimrc_simple /home/hidetomo/.vimrc

# share
RUN mkdir /home/hidetomo/share
VOLUME /home/hidetomo/share

# common yum
RUN sudo yum -y install less wget
RUN sudo yum -y install git
RUN sudo yum -y install anaconda

# start
CMD ["sudo /sbin/init"]
# CMD ["sudo systemctl start sshd.service"]
CMD ["/usr/sbin/sshd", "-D"]
