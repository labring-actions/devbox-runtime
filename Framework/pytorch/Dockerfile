FROM ghcr.io/labring-actions/devbox/ubuntu-cuda-24.04:898890
RUN cd /home/devbox/project && \
rm -rf ./*

COPY /GPU/pytorch/project /home/devbox/project

RUN apt-get update && \
    curl -O https://repo.anaconda.com/archive/Anaconda3-2024.10-1-Linux-x86_64.sh && \
    bash Anaconda3-2024.10-1-Linux-x86_64.sh -b && \
    rm Anaconda3-2024.10-1-Linux-x86_64.sh && \
    /root/anaconda3/bin/conda init bash && \
    . /root/.bashrc && \
    conda create -y -n hello python=3.12 && \
    conda activate hello && \
    pip3 install torch torchvision torchaudio && \
    chown -R devbox:devbox /home/devbox/project && \
    chmod -R u+rw /home/devbox/project && \
    chmod -R +x /home/devbox/project/entrypoint.sh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* 

RUN mkdir /home/devbox/.devbox