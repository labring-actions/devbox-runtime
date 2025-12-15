# Laravel Web 应用程序示例

这是一个使用 Laravel 5.8.5 构建的现代 PHP Web 应用程序示例，Laravel 是一个强大的 MVC 框架，提供优雅的语法和工具用于构建强大的 Web 应用程序。

## 项目描述

该项目使用 Laravel 创建一个全面的 Web 应用程序。该应用展示了 Laravel 的核心功能，包括其强大的 ORM（Eloquent）、路由系统、中间件和 Blade 模板引擎。服务器监听 8000 端口，为构建 Web 应用程序提供干净、表达力强的语法。Laravel 的广泛生态系统和内置功能使其非常适合使用更少的代码和更多的灵活性构建复杂的、数据库驱动的网站和应用程序。

## 运行环境

该项目在带有 PHP 7.4 和 Laravel 5.8.5 的 Debian 12 系统上运行，这些环境已在 Devbox 中预配置。您无需担心自己设置 PHP、Composer 或 Laravel 依赖项。开发环境包含构建和运行 Laravel 应用程序所需的所有工具。如果您需要进行调整以满足特定需求，可以相应地修改配置文件。

## 项目执行

**开发模式：** 对于正常开发环境，直接进入 Devbox 并在终端中运行 `bash entrypoint.sh`。这将安装依赖并启动 Laravel 开发服务器。

**生产模式：** 发布后，项目将根据 `entrypoint.sh` 脚本和命令参数自动打包成 Docker 镜像并部署（运行 `bash entrypoint.sh production`）。这将安装生产依赖并启动 Laravel 服务器。


DevBox: 编码、构建、部署，我们来打理其余工作。

使用 DevBox，您可以专注于编写优秀代码，其余基础设施、扩展和部署交由我们处理。从开发到生产的无缝体验。

