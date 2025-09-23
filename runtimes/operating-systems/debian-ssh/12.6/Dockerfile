FROM debian:12.6-slim

COPY startup.sh /usr/start/startup.sh

RUN chmod +x /usr/start/startup.sh && \
    apt-get update && \
    apt-get install -y \
    dumb-init \
    wget \
    sudo \
    net-tools \
    iproute2 \
    iputils-ping \
    curl \
    netcat-openbsd \
    vim \
    openssl \
    make \
    git \
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
    sudo chmod -R 777 /home/devbox/project

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["sudo", "-E", "/usr/start/startup.sh"]

WORKDIR /home/devbox/project
EXPOSE 22

# DO CN PATCH in the end of the Dockerfile
ARG CN_PATCH_ENABLED=false
# Copy debian.sources to tmp directory, if cn patch is enabled, copy it to /etc/apt/sources.list.d/debian.sources
COPY debian.sources /tmp/debian.sources
RUN if [ "$CN_PATCH_ENABLED" = "true" ]; then \
       sudo cp /tmp/debian.sources /etc/apt/sources.list.d/debian.sources; \
    fi
