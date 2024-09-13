FROM ghcr.io/labring-actions/devbox/debian-ssh-12.6:a9c28d

RUN cd /home/sealos/project && \
rm -rf ./*

COPY /Language/node.js/project /home/sealos/project

RUN apt-get update && \
    apt-get install -y curl && \
    curl -sL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g typescript yarn pnpm && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    chown -R sealos:sealos /home/sealos/project && \
    chmod -R u+rw /home/sealos/project

RUN mkdir /root/.sealos