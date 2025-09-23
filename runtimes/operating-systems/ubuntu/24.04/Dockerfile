FROM ubuntu:24.04

COPY startup.sh /usr/start/startup.sh

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
    echo 'AuthorizedKeysFile  /usr/start/.ssh/authorized_keys' >> /etc/ssh/sshd_config && \
    echo 'PasswordAuthentication no' >> /etc/ssh/sshd_config && \
    echo 'PermitRootLogin prohibit-password' >> /etc/ssh/sshd_config && \
    useradd -m -s /bin/bash devbox && \
    usermod -aG sudo devbox && \
    echo 'devbox ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    rm -rf /tmp/* && \
    mkdir -p /home/devbox/.ssh && \
    PASS=$(openssl rand -base64 16) && \
    echo "devbox:$PASS" | sudo chpasswd && \
    chown -R devbox:devbox /home/devbox/.ssh && \
    chmod -R 770 /home/devbox/.ssh

USER devbox
COPY project /home/devbox/project
RUN sudo chown -R devbox:devbox /home/devbox/project && \
    sudo chmod -R 777 /home/devbox/project && \
    sudo chmod -R +x /home/devbox/project/entrypoint.sh


USER root

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["sudo", "-E", "/usr/start/startup.sh"]

WORKDIR /home/devbox/project

EXPOSE 22
ARG CN_PATCH_ENABLED=false
# Copy sources.list to tmp directory, if cn patch is enabled, copy it to /etc/apt/sources.list
COPY sources.list /tmp/sources.list
RUN if [ "$CN_PATCH_ENABLED" = "true" ]; then \
        sudo cp /tmp/sources.list /etc/apt/sources.list; \
    fi
