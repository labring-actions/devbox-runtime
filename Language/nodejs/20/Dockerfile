FROM ghcr.io/labring-actions/devbox/debian-ssh:d8f335

COPY /Language/nodejs/workspace /home/sealos/workspace

RUN apt-get update && \
    apt-get install -y curl && \
    curl -sL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g typescript yarn pnpm && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    chown -R sealos:sealos /home/sealos/workspace && \
    chmod -R u+rw /home/sealos/workspace

RUN mkdir /root/.sealos