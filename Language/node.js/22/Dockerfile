FROM ghcr.io/labring-actions/devbox/debian-ssh-12.6:501781

RUN cd /home/devbox/project && \
rm -rf ./*

COPY /Language/node.js/project /home/devbox/project

RUN apt-get update && \
    apt-get install -y curl && \
    curl -sL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g typescript yarn pnpm && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    chown -R devbox:devbox /home/devbox/project && \
    chmod -R u+rw /home/devbox/project && \
    chmod -R +x /home/devbox/project/entrypoint.sh
 
RUN mkdir /root/.devbox