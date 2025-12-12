# Java HTTP 服务器示例

这是一个简单的 Java HTTP 服务器应用程序，演示了使用 Java 内置 HTTP 服务器的基本服务器功能。

## 项目描述

该项目使用 Java 的 com.sun.net.httpserver 包创建一个轻量级 HTTP 服务器。服务器监听 8080 端口，访问时返回 "Hello World!" 消息。该项目支持开发和生产环境模式。

## 运行环境

该项目在安装了 Java 17 的 Debian 12 系统上运行。环境已在 Devbox 中预配置，因此您无需担心自己设置 Java 或系统依赖项。如果您需要进行调整以满足特定需求，可以相应地修改配置文件。

## 项目执行

**开发模式：** 对于正常开发环境，直接进入 Devbox 并在终端中运行 `bash entrypoint.sh`。这将编译并运行 Java 应用程序。

**生产模式：** 发布后，项目将根据 `entrypoint.sh` 脚本（运行 `bash entrypoint.sh production`）自动打包成 Docker 镜像并部署。


DevBox: 编码、构建、部署，我们来打理其余工作。

使用 DevBox，您可以专注于编写优秀代码，其余基础设施、扩展和部署交由我们处理。从开发到生产的无缝体验。 