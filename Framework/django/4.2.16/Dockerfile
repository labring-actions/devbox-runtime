FROM ghcr.io/labring-actions/devbox/python-3.12:9361af9

RUN cd /home/devbox/project && \
rm -rf ./*
COPY /Framework/django/4.2.16/project /home/devbox/project
 
RUN chown -R devbox:devbox /home/devbox/project && \
    chmod -R u+rw /home/devbox/project && \
    chmod -R +x /home/devbox/project/entrypoint.sh

USER devbox
RUN python3 -m venv /home/devbox/project && \
    cd /home/devbox/project && \
    . bin/activate && \
    pip3 install  django==4.2.16 && \
    deactivate 

RUN mkdir -p /home/devbox/.devbox