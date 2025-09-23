#!/bin/bash
# make sure the script exits on error
set -e

# check nginx config
nginx -t

# run nginx in foreground
exec nginx -g 'daemon off;'