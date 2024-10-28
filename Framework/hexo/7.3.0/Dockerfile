FROM ghcr.io/labring-actions/devbox/node.js-20:b3361c

RUN rm -r /home/devbox/project && \
mkdir -p /home/devbox/project && \
chown -R devbox:devbox /home/devbox/project && \
chmod -R u+rw /home/devbox/project

USER devbox
RUN sudo npm install -g hexo-cli && \
hexo init /home/devbox/project && \
cd /home/devbox/project && \
npm install
COPY /Framework/hexo/7.3.0/entrypoint.sh /home/devbox/project/entrypoint.sh

USER root
RUN chown -R devbox:devbox /home/devbox/project/entrypoint.sh && \
chmod -R 777 /home/devbox/project/entrypoint.sh

RUN mkdir /home/devbox/.devbox