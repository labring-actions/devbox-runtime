FROM ghcr.io/labring-actions/devbox/node.js-20:5c2eec

RUN cd /home/sealos/project && \
rm -rf ./*

RUN mkdir -p /home/sealos/project && \
chown -R sealos:sealos /home/sealos/project && \
chmod -R u+rw /home/sealos/project && \
chmod -R +x /home/sealos/project/entrypoint.sh

USER sealos
RUN  npm install -g hexo-cli && \
hexo init /home/sealos/project && \
cd /home/sealos/project && \
npm install
COPY /Framework/hexo/7.3.0/entrypoint.sh /home/sealos/project/entrypoint.sh
RUN mkdir /home/sealos/.sealos