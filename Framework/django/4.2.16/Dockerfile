FROM ghcr.io/labring-actions/devbox/python-3.12:d4059a

RUN cd /home/sealos/project && \
rm -rf ./*
COPY /Framework/django/4.2.16/project /home/sealos/project

RUN chown -R sealos:sealos /home/sealos/project && \
    chmod -R u+rw /home/sealos/project && \
    chmod -R +x /home/sealos/project/entrypoint.sh

USER sealos
RUN python3 -m venv /home/sealos/project && \
    cd /home/sealos/project && \
    . bin/activate && \
    pip3 install  django==4.2.16 && \
    deactivate 

RUN mkdir /home/sealos/.sealos