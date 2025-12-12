# .NET Web API 示例

这是一个简单的 ASP.NET Core Web 应用程序示例，演示了基本的 HTTP 服务器功能。

## 项目描述

该项目创建了一个最小的 .NET Web API，监听 8080 端口，访问时返回 "Hello, World" 消息。项目支持开发环境和生产环境两种模式。

## 运行环境

该项目在预配置了 .NET 8 的 Debian 12 系统上运行（Devbox 环境）。您无需担心手动设置 .NET SDK 或运行时依赖项。开发环境包含构建和运行 ASP.NET Core 应用程序所需的所有工具。如果需要针对特定需求进行调整，可以相应修改项目配置文件。

## 项目执行

**开发模式：** 在常规开发环境中，直接进入 Devbox 并在终端运行 `bash entrypoint.sh`。这将使用 `dotnet run` 运行应用程序。

**生产模式：** 发布后，项目将根据 `entrypoint.sh` 脚本使用生产参数自动打包为 Docker 镜像并部署（运行 `bash entrypoint.sh production`）。这将发布 Release 配置的应用程序并运行已发布的 DLL。

DevBox: 编码、构建、部署，我们来打理其余工作。

使用 DevBox，您可以专注于编写优秀代码，其余基础设施、扩展和部署交由我们处理。从开发到生产的无缝体验。 