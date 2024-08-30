# Use a base image with the specified platform
FROM ubuntu:latest

# Update apt sources and install required tools
RUN apt update && \
    apt install -y \
    net-tools \
    iproute2 \
    iputils-ping \
    curl \
    vim \
    openssl \
    make \
    git && \
    mkdir -p /usr/start && \
    # Clean up apt cache
    apt clean