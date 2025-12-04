#!/usr/bin/env bash
set -euo pipefail

L10N=${L10N:-en_US}
DEFAULT_DEVBOX_USER=${DEFAULT_DEVBOX_USER:-devbox}

# Install Go 1.23.0
curl -O https://dl.google.com/go/go1.23.0.linux-amd64.tar.gz && \
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.23.0.linux-amd64.tar.gz


# Set up Go for root
if [ $L10N = "zh_CN" ]; then
    echo "export GOPROXY=https://goproxy.cn,direct" >> $HOME/.bashrc
fi
mkdir -p $HOME/go/bin && \
echo 'export GOPATH=$HOME/go' >> $HOME/.bashrc && \
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bashrc

# Set up Go for devbox user
su - ${DEFAULT_DEVBOX_USER}
if [ $L10N = "zh_CN" ]; then
    echo "export GOPROXY=https://goproxy.cn,direct" >> $HOME/.bashrc
fi
mkdir -p $HOME/go/bin && \
echo "export GOPATH=$HOME/go" >> $HOME/.bashrc && \
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bashrc