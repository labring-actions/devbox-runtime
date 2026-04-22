# 镜像构建工作流

本文档说明当前正式构建入口，以及 `tooling/`、`base-images/`、`runtime-images/`、`tests/runtime-smoke/` 之间的关系。

## 工作流入口

- `.github/workflows/build-runtime-images.yaml`
- `.github/workflows/test-runtime-smoke.yaml`

其中：

- `build-runtime-images.yaml` 负责发布 `tooling` 工具镜像、基础镜像和运行时镜像
- `test-runtime-smoke.yaml` 负责对 `runtime-images/` 产物执行 smoke test

## 目录约定

- `tooling/`: `tooling` 镜像的构建上下文和公共脚本
- `base-images/`: 基础镜像定义，按 `operating-systems / languages / frameworks` 分层
- `runtime-images/`: 最终运行时镜像定义
- `tests/runtime-smoke/`: 与 `runtime-images/` 对齐的 smoke test 脚本

## Build Runtime Images

`build-runtime-images.yaml` 是唯一的发布入口，适合以下场景：

- 一次触发完成目标及依赖链
- 对单个 image 或 runtime 做增量发布
- 在同一套流程里同时支持 GHCR 和阿里云 ACR

核心输入：

- `release_tag`: 本次发布版本
- `target`: `all | image/os/<path> | image/lang/<path> | image/fw/<path> | runtime/os/<path> | runtime/lang/<path> | runtime/fw/<path>`
- `profile`: `quick | full | release`
- `overrides_json`: 可选版本覆盖，支持 `tools / os / framework / node / runtime`
- `l10n`、`arch`、`aliyun_enabled`: 常用可选项

其中：

- `quick`: 只构建目标本身，不补依赖
- `full`: 自动补齐依赖链，适合日常手工构建
- `release`: 自动启用 `l10n=both` 与 `arch=both`

## 推荐触发方式

### 1. 全量发布

- `target=all`
- `profile=release`

### 2. 构建单个 framework runtime，并补齐依赖

- `target=runtime/fw/<framework>/<version>`
- `profile=full`

例如：

- `target=runtime/fw/sandbox/v1`

### 3. 只重跑某一层

- `target=image/fw/sandbox/v1` 或 `target=runtime/fw/sandbox/v1`
- `profile=quick`

注意：`quick` 依赖目标所需的上游镜像已经存在于目标 registry，否则会在 `FROM` 阶段失败。

## 镜像命名约定

当前正式流程使用三套仓库：

- `tooling/` -> `ghcr.io/<owner>/devbox-tooling/tooling:<tag>`
- `base-images/` -> `ghcr.io/<owner>/devbox-base-images/...`
- `runtime-images/` -> `ghcr.io/<owner>/devbox-runtime-images/...`

阿里云 ACR 开启后沿用相同层级，只替换 registry 和 namespace。

## 阿里云所需 Secrets

- `ALIYUN_REGISTRY`
- `ALIYUN_USERNAME`
- `ALIYUN_PASSWORD`
- `ALIYUN_NAMESPACE`

建议确认：

- `ALIYUN_REGISTRY` 是实际 registry 地址
- `ALIYUN_NAMESPACE` 只填命名空间，不带仓库名
- 账号具备目标命名空间推送权限
- workflow dispatch 时显式打开 `aliyun_enabled=true`

## Test Runtime Smoke

`test-runtime-smoke.yaml` 用于验证 `runtime-images/` 中的产物是否可用。

核心输入：

- `tag`: 运行时镜像 tag，不包含本地化后缀
- `kind`: `all | operating-systems | languages | frameworks`
- `name`: 可选，指定某个目录名，仅测试单个目标

工作流会：

- 从 `runtime-images/` 生成测试矩阵
- 根据 `tests/runtime-smoke/` 下的相对路径定位测试脚本
- 默认拉取 `en-us` 产物
- 在 `amd64` 和 `arm64` 上分别执行 smoke test

## 常见问题

### `target` 应该填什么

示例：

- `image/fw/sandbox/v1`
- `runtime/fw/sandbox/v1`
- `image/lang/node.js/22`
- `runtime/lang/node.js/22`
- `image/os/debian/12.6`
- `runtime/os/debian/12.6`

不要填写 Dockerfile 绝对路径。

### 构建 framework runtime 需要触发几次

通常只需要一次：

- `target=runtime/fw/<framework>/<version>`
- `profile=full`

### 为什么开启阿里云后仍未推送成功

优先检查：

- 是否真的开启了 `aliyun_enabled`
- 相关 secrets 是否完整
- namespace 与 registry 是否匹配
- 多架构分片镜像是否已先成功推送
