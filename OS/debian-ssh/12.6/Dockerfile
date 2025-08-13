FROM debian:12.6

COPY ./script/startup.sh /usr/start/startup.sh

RUN chmod +x /usr/start/startup.sh && \
    apt-get update && \
    apt-get install -y \
    dumb-init \
    wget \
    sudo \
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
COPY ./OS/debian-ssh/project /home/devbox/project
RUN sudo chown -R devbox:devbox /home/devbox/project && \
    sudo chmod -R 777 /home/devbox/project

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["sudo", "-E", "/usr/start/startup.sh"]
 
WORKDIR /home/devbox/project
EXPOSE 22