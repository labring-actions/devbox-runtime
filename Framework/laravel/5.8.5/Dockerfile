FROM ghcr.io/labring-actions/devbox/php-8.2.20:73f430

RUN cd /home/sealos/project && \
rm -rf ./*

USER sealos
RUN  export TERM=dumb && bash -c "$(curl -fsSL https://php.new/install/linux)"


USER root
RUN  export TERM=dumb && bash -c "$(curl -fsSL https://php.new/install/linux)"

USER sealos
RUN  cd /home/sealos && \ 
laravel new project -q
COPY  /Framework/laravel/5.8.5/project /home/sealos/project

USER root
RUN mkdir /root/.sealos