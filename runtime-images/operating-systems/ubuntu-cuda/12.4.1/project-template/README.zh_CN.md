# Ubuntu CUDA 12.4.1 运行时模板

该模板提供一个基于 Ubuntu CUDA 12.4.1 的最小化**GPU 就绪操作系统运行时**。
适用于你希望先具备 CUDA 基础环境，再安装 AI/计算框架的场景。

## 运行时概览

- 系统/CUDA 版本：`ubuntu-cuda-12.4.1`
- 基础运行时镜像：`ubuntu-cuda-12.4.1`
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

- 在此基础上安装 CUDA 相关框架（如 PyTorch、TensorFlow 或自研 CUDA 应用）。
- 将 `entrypoint.sh` 改为模型服务或计算任务的启动脚本。
- 根据工作负载要求配置 GPU 调度与端口暴露。
