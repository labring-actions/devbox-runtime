#!/bin/bash
# 确保脚本在出错时退出
set -e

# 检查 nginx 配置是否正确
nginx -t

# 前台启动 nginx（这样可以保持容器运行）
exec nginx -g 'daemon off;'