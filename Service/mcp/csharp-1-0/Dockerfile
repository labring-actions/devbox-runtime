FROM ghcr.io/labring-actions/devbox/debian-ssh-12.6:547a61

USER root
RUN cd /home/devbox/project && \
rm -rf ./*

COPY /Service/mcp/csharp-1-0/project /home/devbox/project

RUN chown -R devbox:devbox /home/devbox/project && \
chmod -R u+rw /home/devbox/project && \
chmod -R +x /home/devbox/project/entrypoint.sh

# Install dotnet
RUN apt update && \
    apt install -y wget && \
    wget https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
    sudo dpkg -i packages-microsoft-prod.deb && \
    rm packages-microsoft-prod.deb && \
    sudo apt-get update && \
    sudo apt-get install -y dotnet-sdk-9.0 && \
    chown -R devbox:devbox /home/devbox/project && \
    chmod -R u+rw /home/devbox/project && \
    chmod -R +x /home/devbox/project/entrypoint.sh && \
    rm -rf /var/lib/apt/lists/*


RUN mkdir -p /home/devbox/.devbox