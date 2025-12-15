# Spring Boot Web 应用程序示例

这是一个使用 Spring Boot 3.3.2 构建的现代 Java Web 应用程序示例，Spring Boot 是一个强大的框架，简化了生产就绪应用程序的开发。

## 项目描述

该项目使用 Spring Boot 创建一个轻量级、RESTful Web 服务。该应用展示了 Spring Boot 的自动配置功能和嵌入式应用服务器。服务器监听 8080 端口，可以轻松扩展以创建 RESTful 端点。Spring Boot 的约定优于配置方法减少了样板代码和配置，使开发人员能够专注于业务逻辑而不是基础设施问题。

## 运行环境

该项目在带有 Java 17 和 Spring Boot 3.3.2 的 Debian 12 系统上运行，这些环境已在 Devbox 中预配置。您无需担心自己设置 Java、Maven 或 Spring Boot 依赖项。开发环境包含构建和运行 Spring Boot 应用程序所需的所有工具。如果您需要进行调整以满足特定需求，可以相应地修改配置文件。

## 项目执行

**开发模式：** 对于正常开发环境，直接进入 Devbox 并在终端中运行 `bash entrypoint.sh`。这将使用 Maven 的 spring-boot:run 命令编译并启动 Spring Boot 应用程序。

**生产模式：** 发布后，项目将根据 `entrypoint.sh` 脚本和命令参数自动打包成 Docker 镜像并部署（运行 `bash entrypoint.sh production`）。这将清理、安装并运行 Spring Boot 应用程序。


DevBox: 编码、构建、部署，我们来打理其余工作。

使用 DevBox，您可以专注于编写优秀代码，其余基础设施、扩展和部署交由我们处理。从开发到生产的无缝体验。

