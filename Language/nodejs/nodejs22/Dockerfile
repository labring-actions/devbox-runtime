FROM ghcr.io/labring-actions/devbox/debian-ssh:d8f335

COPY /Language/nodejs/workspace /home/sealos/workspace

RUN apt-get update && \
    apt-get install -y curl && \
    curl -sL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g typescript yarn pnpm && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir /root/.sealos