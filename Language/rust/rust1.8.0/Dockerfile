FROM ghcr.io/labring-actions/devbox/debian-ssh:d8f335

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    apt-get update && \
    apt-get install -y  build-essential  && \
    apt-get clean && \
    echo 'export PATH=/root/.cargo/bin:$PATH' >> /home/sealos/.bashrc && \
    rm -rf /var/lib/apt/lists/*