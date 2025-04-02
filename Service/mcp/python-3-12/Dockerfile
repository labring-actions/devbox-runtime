FROM ghcr.io/labring-actions/devbox/python-3.12:13aacd

RUN cd /home/devbox/project && \
rm -rf ./*
COPY /Service/mcp/python-3-12/project /home/devbox/project

USER devbox
RUN python3 -m venv /home/devbox/project && \
    cd /home/devbox/project && \
    . bin/activate && \
    pip3 install "mcp[cli]==1.6.0" && \
    deactivate
