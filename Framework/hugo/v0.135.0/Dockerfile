FROM ghcr.io/labring-actions/devbox/go-1.22.5:8c965d

RUN rm -r /home/sealos/project 

USER sealos
RUN curl -LO https://github.com/gohugoio/hugo/releases/download/v0.135.0/hugo_extended_0.135.0_linux-amd64.tar.gz && \
tar -xvzf hugo_extended_0.135.0_linux-amd64.tar.gz && \
sudo mv hugo /usr/local/bin/ && \
sudo chmod +x /usr/local/bin/hugo && \
rm README.md && rm LICENSE && rm hugo_extended_0.135.0_linux-amd64.tar.gz && \
cd /home/sealos && \
hugo new site project && \
cd project && \
git init && \
git submodule add https://github.com/theNewDynamic/gohugo-theme-ananke.git themes/ananke && \
echo "theme = 'ananke'" >> hugo.toml && \
hugo
 
COPY /Framework/hugo/v0.135.0/project /home/sealos/project

USER root

RUN chown -R sealos:sealos /home/sealos/project && \
chmod -R u+rw /home/sealos/project  && \
chmod -R +x /home/sealos/project/entrypoint.sh

RUN mkdir /home/sealos/.sealos