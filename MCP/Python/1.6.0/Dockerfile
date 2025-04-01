FROM ghcr.io/labring-actions/devbox/python-3.12:13aacd

RUN cd /home/devbox/project && \
rm -rf ./*
COPY /MCP/Python/1.6.0/project /home/devbox/project

RUN chown -R devbox:devbox /home/devbox/project && \
    chmod -R u+rw /home/devbox/project && \
    chmod -R +x /home/devbox/project/entrypoint.sh

USER devbox
RUN python3 -m venv /home/devbox/project && \
    cd /home/devbox/project && \
    . bin/activate && \
    pip3 install "mcp[cli]==1.6.0" && \
    deactivate

RUN mkdir -p /home/devbox/.devbox