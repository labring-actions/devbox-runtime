# Vert.x Web 服务器示例

这是一个使用 Vert.x 4.5.10 构建的响应式 Web 服务器应用程序示例，Vert.x 是一个用于在 JVM 上构建响应式应用程序的工具包。

## 项目描述

该项目使用 Vert.x 创建一个轻量级、高性能 HTTP 服务器。服务器监听 8888 端口，访问时返回"Hello from Vert.x!"消息。基于 Vert.x 的事件驱动、非阻塞模型构建，此示例展示了响应式编程的核心概念和 Vert.x 的 verticle 部署模式。

## 运行环境

该项目在带有 Java 17 和 Vert.x 4.5.10 的 Debian 12 系统上运行，这些环境已在 Devbox 中预配置。您无需担心自己设置 Java、Maven 或 Vert.x 依赖项。开发环境包含构建和运行 Vert.x 应用程序所需的所有工具。如果您需要进行调整以满足特定需求，可以相应地修改配置文件。

## 项目执行

**开发模式：** 对于正常开发环境，直接进入 Devbox 并在终端中运行 `bash entrypoint.sh`。这将使用 Maven wrapper 编译并运行 Vert.x 应用程序。

**生产模式：** 发布后，项目将根据 `entrypoint.sh` 脚本和命令参数自动打包成 Docker 镜像并部署（运行 `bash entrypoint.sh production`）。这将使用 Maven wrapper 构建 fat JAR 并从中运行应用程序。


DevBox: 编码、构建、部署，我们来打理其余工作。

使用 DevBox，您可以专注于编写优秀代码，其余基础设施、扩展和部署交由我们处理。从开发到生产的无缝体验。

