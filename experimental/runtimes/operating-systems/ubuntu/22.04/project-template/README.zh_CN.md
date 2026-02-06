# Ubuntu 22.04 运行时模板

该模板提供一个基于 Ubuntu 22.04 的最小化**操作系统运行时**。
适用于你希望使用通用 Ubuntu 环境并完全掌控软件栈的场景。

## 运行时概览

- 系统版本：`Ubuntu 22.04`
- 基础运行时镜像：`ubuntu-22.04`
- 启动脚本：`entrypoint.sh`
- 默认服务端口：`8080`

## 模板文件

- `entrypoint.sh`：生成静态 `index.html` 并启动 `busybox httpd`

## 在 DevBox 中运行

以下命令在 `/home/devbox/project` 目录执行。

```bash
bash entrypoint.sh
```

行为说明：
- 支持通过 `PORT` 环境变量覆盖端口，默认值为 `8080`。
- 默认从 `/home/devbox/project/www` 目录提供静态内容。

## 验证服务

```bash
curl http://127.0.0.1:8080
```

预期输出：

```text
Hello, World!
```

## 自定义建议

- 可将 `entrypoint.sh` 替换为你的进程启动脚本。
- 在该 Ubuntu 基础镜像中安装业务依赖或工具链。
- 保持容器暴露端口与服务监听端口一致。
