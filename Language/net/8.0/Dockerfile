FROM ghcr.io/labring-actions/devbox/debian-ssh-12.6:d720f6

RUN cd /home/sealos/project && \
rm -rf ./*

COPY /Language/net/project /home/sealos/project

RUN apt update && \
    apt install -y wget && \
    wget https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
    sudo dpkg -i packages-microsoft-prod.deb && \
    rm packages-microsoft-prod.deb && \
    sudo apt-get update && \
    sudo apt-get install -y dotnet-sdk-8.0 && \
    cd /home/sealos/project && \
    dotnet new console && \
    dotnet build && \
    chown -R sealos:sealos /home/sealos/project && \
    chmod -R u+rw /home/sealos/project && \
    chmod -R +x /home/sealos/project/entrypoint.sh && \
    rm -rf /var/lib/apt/lists/* && \

RUN mkdir /root/.sealos