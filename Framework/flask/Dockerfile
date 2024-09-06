FROM ghcr.io/labring-actions/devbox/python3.12:2539aa

COPY /Framework/flask/project /home/sealos/project

RUN cd /home/sealos/project&&python3.12 -m venv env && \
    chown -R sealos:sealos /home/sealos/project && \
    chmod -R u+rw /home/sealos/project

RUN mkdir /home/sealos/.sealos