# Quarkus Web 应用程序示例

这是一个使用 Quarkus 3.16.1 构建的现代 Java Web 应用程序示例，Quarkus 是一个专为 GraalVM 和 HotSpot 量身定制的 Kubernetes Native Java 框架，旨在专门针对容器环境优化 Java。

## 项目描述

该项目使用 Quarkus 创建一个轻量级 RESTful Web 服务。该应用展示了 Quarkus 的快速启动时间、低内存占用和开发人员友好的功能，如实时编码。服务器监听 8080 端口，并提供简单的 REST 端点，返回"Hello from Quarkus REST"消息。Quarkus 的响应式编程模型确保高效处理 Web 请求，使其非常适合微服务和云原生应用程序。

## 运行环境

该项目在带有 Java 17 和 Quarkus 3.16.1 的 Debian 12 系统上运行，这些环境已在 Devbox 中预配置。您无需担心自己设置 Java、Maven 或 Quarkus 依赖项。开发环境包含构建和运行 Quarkus 应用程序所需的所有工具。如果您需要进行调整以满足特定需求，可以相应地修改配置文件。

## 项目执行

**开发模式：** 对于正常开发环境，直接进入 Devbox 并在终端中运行 `bash entrypoint.sh`。这将使用 Maven wrapper 编译并启动 Quarkus 应用程序，启用开发模式和热重载。

**生产模式：** 发布后，项目将根据 `entrypoint.sh` 脚本和命令参数自动打包成 Docker 镜像并部署（运行 `bash entrypoint.sh production`）。这将使用 Maven wrapper 打包应用程序并运行优化的 JAR。


DevBox: 编码、构建、部署，我们来打理其余工作。

使用 DevBox，您可以专注于编写优秀代码，其余基础设施、扩展和部署交由我们处理。从开发到生产的无缝体验。

