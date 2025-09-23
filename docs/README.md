# DevBox Runtime 文档

## 概述

DevBox Runtime 是一个容器化开发环境管理系统，提供各种编程语言、框架和操作系统的预配置运行时环境。

## 目录结构

- `runtimes/` - 运行时包定义
  - `frameworks/` - 框架运行时（Vue, React, Angular等）
  - `languages/` - 语言运行时（Python, Go, Node.js等）
  - `operating-systems/` - 操作系统运行时（Ubuntu, Debian等）
  - `services/` - 服务运行时（MCP等）

- `config/` - 配置文件
  - `registry.json` - 主配置文件
  - `registry-cn.json` - 中文版配置
  - `mappings/` - 映射配置

## 开发指南

请参考 [development.md](development.md) 了解如何为项目贡献代码。

## API 文档

请参考 [api/](api/) 目录了解详细的API文档。
