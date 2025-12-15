# VitePress 文档站点示例

这是一个使用 VitePress 1.4.0 构建的现代文档站点示例，VitePress 是一个由 Vue 和 Vite 驱动的静态站点生成器。

## 项目描述

该项目使用 VitePress 创建一个文档网站，具有 Markdown 扩展、语法高亮、自定义容器和交互式 Vue 组件。开发服务器监听 4173 端口，并提供即时热更新。该示例包括一个带有可定制英雄部分和功能列表的主页，以及展示 VitePress 强大的 Markdown 和 API 功能的示例页面。

## 运行环境

该项目在带有 Node.js 和 VitePress 1.4.0 的 Debian 12 系统上运行，这些环境已在 Devbox 中预配置。您无需担心自己设置 Node.js、npm 或 VitePress 依赖项。开发环境包含构建和运行 VitePress 文档站点所需的所有工具，包括用于快速开发和优化构建的 Vite。如果您需要进行调整以满足特定需求，可以相应地修改配置文件。

## 项目执行

**开发模式：** 对于正常开发环境，直接进入 Devbox 并在终端中运行 `bash entrypoint.sh`。这将安装依赖并在 4173 端口启动带有热重载功能的 VitePress 开发服务器。

**生产模式：** 发布后，项目将根据 `entrypoint.sh` 脚本和命令参数自动打包成 Docker 镜像并部署（运行 `bash entrypoint.sh production`）。这将安装依赖、构建优化的静态文件并使用 VitePress 的预览服务器提供服务。


DevBox: 编码、构建、部署，我们来打理其余工作。

使用 DevBox，您可以专注于编写优秀代码，其余基础设施、扩展和部署交由我们处理。从开发到生产的无缝体验。

