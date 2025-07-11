FROM ghcr.io/labring-actions/devbox/node.js-20:219d11
# Test comment for GitHub Actions trigger
USER root
RUN cd /home/devbox/project

RUN apt-get update && apt-get install -y nginx

COPY /Framework/nginx/1.22.1/project /home/devbox/project
COPY /Framework/nginx/1.22.1/nginx.conf /etc/nginx/nginx.conf
RUN chown -R devbox:devbox /home/devbox/project && \
chmod -R u+rw /home/devbox/project && \
chmod -R +x /home/devbox/project/entrypoint.sh 

RUN mkdir -p /home/devbox/.devbox