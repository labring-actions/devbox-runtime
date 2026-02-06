# C GCC 12.2.0 运行时模板

该模板为 DevBox **GCC 12.2.0（C）** 运行时提供一个最小可运行的 HTTP 服务。

## 运行时概览

- 编译器版本：`gcc 12.2.0`
- 基础运行时镜像：`c-gcc-12.2.0`
- 启动脚本：`entrypoint.sh`
- 默认服务端口：`8080`（代码中可通过 `PORT` 覆盖）

## 模板文件

- `hello_world.c`：带优雅退出逻辑的 socket HTTP 服务
- `entrypoint.sh`：按模式切换的编译运行脚本

## 在 DevBox 中运行

以下命令在 `/home/devbox/project` 目录执行。

### 开发模式

```bash
bash entrypoint.sh
```

行为说明：
- 使用 `gcc -Wall hello_world.c -o hello_world` 编译
- 运行 `./hello_world`

### 生产模式

```bash
bash entrypoint.sh production
```

行为说明：
- 使用优化参数编译：`gcc -O2 -Wall hello_world.c -o hello_world`
- 运行 `./hello_world`

## 验证服务

```bash
curl http://127.0.0.1:8080
```

预期输出：

```text
Hello, World from Development Server!
```

## 自定义建议

- 在 `hello_world.c` 中扩展请求解析与路由处理。
- 若需非默认端口，可通过环境变量 `PORT` 覆盖。
- 项目复杂后建议引入 Makefile 管理构建。
