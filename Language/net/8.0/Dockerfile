FROM ghcr.io/labring-actions/devbox/debian-ssh-12.6:547a61

RUN cd /home/devbox/project && \
rm -rf ./*

COPY /Language/net/project /home/devbox/project

RUN apt update && \
    apt install -y wget && \
    wget https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
    sudo dpkg -i packages-microsoft-prod.deb && \
    rm packages-microsoft-prod.deb && \
    sudo apt-get update && \
    sudo apt-get install -y dotnet-sdk-8.0 && \
    cd /home/devbox/project && \
    chown -R devbox:devbox /home/devbox/project && \
    chmod -R u+rw /home/devbox/project && \
    chmod -R +x /home/devbox/project/entrypoint.sh && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir /root/.devbox
