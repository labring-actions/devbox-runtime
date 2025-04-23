#!/bin/bash

# 激活虚拟环境
source /home/devbox/project/.venv/bin/activate

# 添加当前目录到Python路径
export PYTHONPATH=$PYTHONPATH:/home/devbox/project

# 检测环境
if [ "$1" = "dev" ]; then
  echo "Development environment detected"
  echo "Running development environment commands..."
  # 开发环境命令
  cd /home/devbox/project && python -m project
else
  echo "Production environment detected"
  echo "Running production environment commands..."
  # 生产环境命令
  cd /home/devbox/project && python -m project
fi

# 退出虚拟环境
deactivate
