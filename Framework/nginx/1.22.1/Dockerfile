FROM ghcr.io/labring-actions/devbox/node.js-20:b3361c

RUN cd /home/devbox/project

RUN apt-get update && apt-get install -y nginx

COPY /Framework/nginx/1.22.1/project /home/devbox/project
RUN chown -R devbox:devbox /home/devbox/project && \
chmod -R u+rw /home/devbox/project && \
chmod -R +x /home/devbox/project/entrypoint.sh
 
USER root
RUN mkdir /home/devbox/.devbox