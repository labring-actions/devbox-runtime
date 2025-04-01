FROM ghcr.io/labring-actions/devbox/debian-ssh-12.6:547a61

USER root
RUN cd /home/devbox/project && \
rm -rf ./*

COPY /Service/mcp/csharp-1-0/project /home/devbox/project
RUN chown -R devbox:devbox /home/devbox/project && \
chmod -R u+rw /home/devbox/project && \
chmod -R +x /home/devbox/project/entrypoint.sh

# Install dotnet
USER devbox
RUN cd /home/devbox/project && \
sudo wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh && \
sudo chmod -R +x ./dotnet-install.sh && \
sudo ./dotnet-install.sh --version 9.0.100 -InstallDir /usr/share/dotnet/ && \
sudo echo 'export PATH=$PATH:/usr/share/dotnet/' >> ~/.bashrc && \
sudo source ~/.bashrc && \
sudo apt-get update && sudo apt-get install -y libicu-dev && \


RUN mkdir -p /home/devbox/.devbox