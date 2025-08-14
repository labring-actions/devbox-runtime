FROM ghcr.io/labring-actions/devbox/python-3.12:3b6f7a9

RUN cd /home/devbox/project && \
rm -rf ./*
COPY /Framework/flask/3.0.3/project /home/devbox/project

RUN chown -R devbox:devbox /home/devbox/project && \
    chmod -R u+rw /home/devbox/project && \
    chmod -R +x /home/devbox/project/entrypoint.sh

USER devbox
RUN python3 -m venv /home/devbox/project && \
    cd /home/devbox/project && \
    . bin/activate && \
    pip3 install flask && \
    deactivate 

USER root
RUN mkdir -p /home/devbox/.devbox