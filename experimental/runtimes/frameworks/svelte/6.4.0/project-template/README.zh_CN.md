# Svelte Web 应用程序示例

这是一个使用 Svelte 6.4.0 和 SvelteKit 构建的现代 Web 应用程序示例，Svelte 是一个渐进式 JavaScript 框架，通过编译时优化专注于高性能。

## 项目描述

该项目使用 Svelte 和 SvelteKit 创建一个响应式单页应用程序。该应用包括一个带有交互式组件的主页、一个关于页面和一个名为"Sverdle"的类似 Wordle 的游戏。它展示了 Svelte 的响应式 UI 系统、组件架构和服务器端渲染功能。开发服务器监听 5173 端口，并提供热模块替换功能，提供流畅的开发体验。

## 运行环境

该项目在带有 Node.js 和 Svelte 6.4.0 的 Debian 12 系统上运行，这些环境已在 Devbox 中预配置。您无需担心自己设置 Node.js、npm 或 Svelte 依赖项。开发环境包含构建和运行 Svelte 应用程序所需的所有工具，包括用于快速开发和优化构建的 Vite。如果您需要进行调整以满足特定需求，可以相应地修改配置文件。

## 项目执行

**开发模式：** 对于正常开发环境，直接进入 Devbox 并在终端中运行 `bash entrypoint.sh`。这将安装依赖并启动带有热重载功能的 Svelte 开发服务器。

**生产模式：** 发布后，项目将根据 `entrypoint.sh` 脚本和命令参数自动打包成 Docker 镜像并部署（运行 `bash entrypoint.sh production`）。这将安装依赖、构建优化的静态文件并使用 Svelte 预览服务器提供服务。


DevBox: 编码、构建、部署，我们来打理其余工作。

使用 DevBox，您可以专注于编写优秀代码，其余基础设施、扩展和部署交由我们处理。从开发到生产的无缝体验。

