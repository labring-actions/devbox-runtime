# Use a base image with the specified platform
FROM debian:stable-slim

# Update apt sources and install required tools
RUN apt update && \
    apt install -y \
    net-tools \
    iproute2 \
    iputils-ping \
    curl \
    sudo \
    netcat-openbsd \
    vim \
    openssl \
    make \
    git && \
    mkdir -p /usr/start && \
    # Clean up apt cache
    apt clean

    # Entry point (modifiable as needed)
CMD ["/bin/bash"]