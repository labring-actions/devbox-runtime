#!/bin/bash

# 确保脚本在发生错误时立即退出
set -e

if [ "$#" -ne 2 ]; then
  echo "Usage: $0  <build_target> <sql>"
  exit 1
fi

BUILD_TARGET=$1
SQL=$2

# 创建目录（如果不存在）
mkdir -p sql/templates/

# 将build_target中的斜杠替换为下划线，用于文件名
BUILD_TARGET_FILENAME=$(echo "$BUILD_TARGET" | sed 's/\//_/g')

# 保存SQL到文件
echo "$SQL" > "/sql/templates/${BUILD_TARGET_FILENAME}.sql"

echo "SQL saved to /sql/templates/${BUILD_TARGET_FILENAME}.sql"
