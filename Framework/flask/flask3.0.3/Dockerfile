FROM ghcr.io/labring-actions/devbox/python3.12:6e6ed1

COPY /Framework/flask/project /home/sealos/project

RUN chown -R sealos:sealos /home/sealos/project && \
    chmod -R u+rw /home/sealos/project && \
    python3 -m venv /home/sealos/project && \
    cd /home/sealos/project && \
    source bin/activate && \
    pip3 install flask && \
    deactivate 

RUN mkdir /home/sealos/.sealos