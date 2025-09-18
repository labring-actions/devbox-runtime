# DevBox Runtime 文档

## 概述

DevBox Runtime 是一个容器化开发环境管理系统，提供各种编程语言、框架和操作系统的预配置运行时环境。

## 目录结构

- `runtimes/` - 运行时包定义
  - `frameworks/` - 框架运行时（Vue, React, Angular等）
  - `languages/` - 语言运行时（Python, Go, Node.js等）
  - `operating-systems/` - 操作系统运行时（Ubuntu, Debian等）
  - `services/` - 服务运行时（MCP等）

- `tools/` - 工具和脚本
  - `build/` - 构建相关脚本
  - `generate/` - 生成相关脚本
  - `utils/` - 工具脚本
  - `common/` - 通用脚本

- `config/` - 配置文件
  - `registry.json` - 主配置文件
  - `registry-cn.json` - 中文版配置
  - `mappings/` - 映射配置

## 使用方法

### 使用 runtimectl 工具

```bash
# 列出所有可用的运行时
./runtimectl list

# 列出特定类型的运行时
./runtimectl list-frameworks
./runtimectl list-languages
./runtimectl list-os

# 查看运行时详细信息
./runtimectl info vue v3.4.29

# 扫描并更新运行时元数据
./runtimectl scan
./runtimectl generate-meta
```

### 构建和部署

```bash
# 构建并推送镜像
./runtimectl ci build-and-push <dockerfile> <image1> <image2> [--cn]

# 生成运行时配置
./runtimectl ci generate-config

# 生成启动脚本
./runtimectl ci generate-startup [--output <path>]
```

## 开发指南

请参考 [development.md](development.md) 了解如何为项目贡献代码。

## API 文档

请参考 [api/](api/) 目录了解详细的API文档。
