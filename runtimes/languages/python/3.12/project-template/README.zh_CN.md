# Python 3.12 运行时模板

该模板为 DevBox **Python 3.12** 运行时提供一个最小可运行的 HTTP 服务。

## 运行时概览

- 语言版本：`Python 3.12`
- 基础运行时镜像：`python-3.12`
- 启动脚本：`entrypoint.sh`
- 默认服务端口：`8080`

## 模板文件

- `hello.py`：基于 `http.server` 的 HTTP 服务
- `entrypoint.sh`：开发/生产模式启动脚本

## 在 DevBox 中运行

以下命令在 `/home/devbox/project` 目录执行。

### 开发模式

```bash
bash entrypoint.sh
```

行为说明：
- 若存在 `bin/activate`，会先自动 `source` 虚拟环境。
- 使用 `python3 hello.py` 启动应用。

### 生产模式

```bash
bash entrypoint.sh production
```

行为说明：
- 与开发模式使用同一启动命令（`python3 hello.py`），保证运行路径一致。

## 验证服务

启动后执行：

```bash
curl http://127.0.0.1:8080
```

预期输出：

```text
Hello, World!
```

## 自定义建议

- 在 `hello.py` 中扩展路由或业务逻辑。
- 若需要进程管理，可将 `entrypoint.sh` 替换为 `gunicorn`/`uvicorn` 启动方式。
- 保持容器暴露端口与应用监听端口一致。
