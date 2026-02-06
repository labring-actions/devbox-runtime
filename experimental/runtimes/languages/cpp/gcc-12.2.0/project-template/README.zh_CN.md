# C++ GCC 12.2.0 运行时模板

该模板为 DevBox **GCC 12.2.0（C++）** 运行时提供一个最小可运行的 HTTP 服务。

## 运行时概览

- 编译器版本：`g++ (GCC) 12.2.0`
- 基础运行时镜像：`cpp-gcc-12.2.0`
- 启动脚本：`entrypoint.sh`
- 默认服务端口：`8080`

## 模板文件

- `hello_world.cpp`：基于 socket 的 HTTP 服务
- `entrypoint.sh`：开发/生产模式通用的编译运行脚本

## 在 DevBox 中运行

以下命令在 `/home/devbox/project` 目录执行。

### 开发模式

```bash
bash entrypoint.sh
```

行为说明：
- 执行 `g++ hello_world.cpp -o hello_world` 编译
- 执行 `./hello_world` 运行

### 生产模式

```bash
bash entrypoint.sh production
```

行为说明：
- 与开发模式使用同一编译运行流程。

## 验证服务

```bash
curl http://127.0.0.1:8080
```

预期输出：

```text
Hello, World!
```

## 自定义建议

- 在 `hello_world.cpp` 中扩展路由或协议处理逻辑。
- 项目变大后可引入 `Makefile` 或 CMake。
- 若修改可执行文件名，请同步更新 `entrypoint.sh`。
