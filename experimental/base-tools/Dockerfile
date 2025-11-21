FROM alpine:3.22 AS base-tools
# Install standard tools or just copy scripts
COPY scripts/ /opt/base-tools/scripts/
# Make them executable
RUN chmod -R +x /opt/base-tools/scripts/*