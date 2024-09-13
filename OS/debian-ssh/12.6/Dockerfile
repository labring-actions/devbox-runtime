FROM ghcr.io/labring-actions/devbox/debian:ce4733

COPY /script/startup.sh /usr/start/startup.sh

RUN chmod +x /usr/start/startup.sh && \
    apt-get update && \
    apt-get install -y \
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
    useradd -m -s /bin/bash sealos && \
    usermod -aG sudo sealos && \
    echo 'sealos ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    rm -rf /tmp/*

USER sealos
COPY /OS/debian-ssh/project /home/sealos/project
RUN sudo chown -R sealos:sealos /home/sealos/project && \
    sudo chmod -R 777 /home/sealos/project

USER root
ENTRYPOINT ["sudo", "-E", "/usr/start/startup.sh"]

WORKDIR /home/sealos/project
EXPOSE 22