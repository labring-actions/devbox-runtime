FROM alpine:3.22 AS configure-tools
# Install standard tools or just copy scripts
COPY scripts/ /opt/configure-tools/scripts/
# Make them executable
RUN chmod -R +x /opt/configure-tools/scripts/*