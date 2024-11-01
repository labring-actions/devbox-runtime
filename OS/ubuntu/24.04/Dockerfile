FROM ubuntu:latest

COPY /script/startup.sh /usr/start/startup.sh

RUN apt update && \
    apt install -y \
    net-tools \
    iproute2 \
    iputils-ping \
    curl \
    sudo \
    wget \
    netcat-openbsd \
    vim \
    openssl \
    make \
    git && \
    mkdir -p /usr/start && \
    apt clean

RUN chmod +x /usr/start/startup.sh && \
    apt-get update && \
    apt-get install -y \
    dumb-init \
    openssh-client \
    openssh-server && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /run/sshd  && \
    chmod 755 /run/sshd && \
    echo 'AllowTcpForwarding yes' >> /etc/ssh/sshd_config && \
    echo 'GatewayPorts yes' >> /etc/ssh/sshd_config && \
    echo 'X11Forwarding yes' >> /etc/ssh/sshd_config && \ 
    echo 'Port 22' >> /etc/ssh/sshd_config && \
    useradd -m -s /bin/bash devbox && \
    usermod -aG sudo devbox && \
    echo 'devbox ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    rm -rf /tmp/* && \
    mkdir -p /home/devbox/.ssh && \
    chown -R devbox:devbox /home/devbox/.ssh && \
    chmod -R 770 /home/devbox/.ssh 

USER devbox
COPY /OS/debian-ssh/project /home/devbox/project
RUN sudo chown -R devbox:devbox /home/devbox/project && \
    sudo chmod -R 777 /home/devbox/project && \
    sudo chmod -R +x /home/devbox/project/entrypoint.sh


USER root

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["sudo", "-E", "/usr/start/startup.sh"]
 
WORKDIR /home/devbox/project
EXPOSE 22