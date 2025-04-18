#!/bin/bash

# 确保脚本在发生错误时立即退出
set -e

# 使用命名参数处理
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --app-port) APP_PORT="$2"; shift ;;
        --ssh-port) SSH_PORT="$2"; shift ;;
        --entrypoint) ENTRYPOINT="$2"; shift ;;
        --user) DEVBOX_USER="$2"; shift ;;
        --working-dir) WORKING_DIR="$2"; shift ;;
        --output) OUTPUT_FILE="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# 检查必需参数
# if [ -z "$RUNTIME_NAME" ] || [ -z "$SHORT_COMMIT_ID" ] || [ -z "$ORG_UID" ]; then
#     echo "Usage: $0 \\
#         [ --app-port <app_port> ] \\
#         [ --ssh-port <ssh_port> ] \\
#         [ --entrypoint <entrypoint> ] \\
#         [ --user <user> ] \\
#         [ --working-dir <working_dir> ] \\
#         [ --output <output_file> ]"
#     exit 1
# fi

# 设置默认值
APP_PORT=${APP_PORT:-3001}
SSH_PORT=${SSH_PORT:-22}
ENTRYPOINT=${ENTRYPOINT:-"/home/devbox/project/entrypoint.sh"}
DEVBOX_USER=${DEVBOX_USER:-"devbox"}
WORKING_DIR=${WORKING_DIR:-"/home/devbox/project"}

# 创建生成配置的函数
generate_template_config() {
    cat <<EOF
{"appPorts":[{"name":"devbox-app-port","port":$APP_PORT,"protocol":"TCP"}],"ports":[{"containerPort":$SSH_PORT,"name":"devbox-ssh-port","protocol":"TCP"}],"releaseArgs":["$ENTRYPOINT"],"releaseCommand":["/bin/bash","-c"],"user":"$DEVBOX_USER","workingDir":"$WORKING_DIR"}
EOF
}

# 生成配置
CONFIG=$(generate_template_config)

# 如果指定了输出文件，则写入文件，否则输出到标准输出
if [ -n "$OUTPUT_FILE" ]; then
    echo "$CONFIG" > "$OUTPUT_FILE"
    echo "Configuration written to $OUTPUT_FILE"
else
    echo "$CONFIG"
fi
