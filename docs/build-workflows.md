# Experimental 镜像构建工作流

本文档说明 experimental 构建的唯一入口：

- `.github/workflows/build-expt.yaml`

它对应 `experimental/images/` 和 `experimental/runtimes/` 下的构建流程，用于发布 experimental base images 与 runtime images。旧的 expt workflow 已删除，不再使用。

## 什么时候用哪个工作流

### `build-expt.yaml`（推荐）

适合以下场景：

- 一次触发完成目标及依赖链
- 降低手工输入字段数量
- 需要在不改 GitHub Secrets 名称的前提下支持阿里云推送

核心输入（简化）：

- `release_tag`: 本次发布版本
- `target`: `all | image/os/<path> | image/lang/<path> | image/fw/<path> | runtime/os/<path> | runtime/lang/<path> | runtime/fw/<path>`
- `profile`: `quick | full | release`
- `overrides_json`: 可选版本覆盖（`tools/os/framework/node/runtime`）
- `l10n`/`arch`/`aliyun_enabled`: 常用可选项

其中：

- `full` 会自动补齐依赖（推荐默认）
- `quick` 只构建目标本身（依赖需提前存在）
- `release` 会自动使用 `l10n=both`、`arch=both`

## 推荐用法（新入口）

### 1. 全量发布所有 experimental images 和 runtimes（一次触发）

在 `build-expt.yaml` 中使用：

- `target=all`
- `profile=release`

### 2. 只构建单个 framework runtime，并补齐依赖

- `target=runtime/fw/<framework>/<version>`，例如 `runtime/fw/sandbox/v1`
- `profile=full`

这会先构建 runtime 需要的 framework image；如果上游 language/OS/tools 缺失，也会一起补齐。

### 3. 只重跑单层，不补前置

- `target=image/fw/sandbox/v1`（或 `runtime/fw/sandbox/v1`）
- `profile=quick`

注意：这要求它依赖的 base image 已经存在于目标 registry 中，否则构建会在 `FROM` 阶段失败。

## 关键输入说明

### `release_tag`

最终镜像 tag 的主版本号。大多数场景直接传本次发布版本，例如：

- `v0.0.1-alpha.2`
- `2026-04-14`
- `latest`

### `overrides_json`

用于高级覆盖依赖版本，JSON 格式：

```json
{"tools":"v0.4.2","os":"v0.4.2","framework":"v0.4.2","node":"latest","runtime":"latest"}
```

未提供的键默认跟随 `release_tag`。`runtime` 未提供时默认跟随 `node`。

### `profile`

- `quick`: 不补前置依赖，速度快
- `full`: 补齐依赖链，适合日常手工构建
- `release`: 补齐依赖链 + 强制 `l10n=both` + `arch=both`

### `target`

统一目标字段，支持：

- `all`
- `image/os/<path>`（例：`image/os/debian/12.6`）
- `image/lang/<path>`（例：`image/lang/node.js/22`）
- `image/fw/<path>`（例：`image/fw/sandbox/v1`）
- `runtime/os/<path>`、`runtime/lang/<path>`、`runtime/fw/<path>`

### `aliyun_enabled`

### `l10n`（`profile=release` 时自动忽略）

- `en_US`
- `zh_CN`
- `both`

### `arch`（`profile=release` 时自动忽略）

- `amd64`
- `arm64`
- `both`

## 阿里云推送需要的 Secrets

新旧 workflow 都继续使用以下同名 secrets（名称不变）：

- `ALIYUN_REGISTRY`
- `ALIYUN_USERNAME`
- `ALIYUN_PASSWORD`
- `ALIYUN_NAMESPACE`

推荐检查以下几点：

- `ALIYUN_REGISTRY` 是实际 registry 地址，例如 `registry.cn-hangzhou.aliyuncs.com`
- `ALIYUN_NAMESPACE` 是命名空间，不要把仓库名一并写进去
- 用户名和密码对应的是能 push 目标命名空间的账号
- 在 workflow dispatch 时显式打开 `aliyun_enabled=true`

## 镜像命名约定

当前 experimental workflow 会按构建类型写入不同仓库：

- `images` -> `ghcr.io/<owner>/devbox-base-expt/...`
- `runtimes` -> `ghcr.io/<owner>/devbox-runtime-expt/...`

阿里云开启后也会沿用相同的镜像名层级，只是 registry 和 namespace 不同。

## 常见问题

### 构建 `sandbox` 需要手动触发几次

推荐用 `build-expt.yaml` + `target=image/fw/sandbox/v1`（或 `runtime/fw/sandbox/v1`）+ `profile=full`，只需要触发 **1 次**。

### 为什么只开了阿里云开关，但没有推送成功

通常优先检查：

- 是否真的勾选了 `aliyun_enabled`
- 相关 Aliyun secrets 是否都已配置
- 命名空间和 registry 是否匹配
- 当前 tag 下的多架构分片是否先成功构建

如果前面的 per-arch 镜像没有推送成功，manifest 阶段也不会成功。

### `target` 应该填什么

填法统一为：

- `image/fw/sandbox/v1`（只构建 framework image）
- `runtime/fw/sandbox/v1`（构建 framework runtime）
- `image/lang/node.js/22`、`runtime/lang/node.js/22`
- `image/os/debian/12.6`、`runtime/os/debian/12.6`

不要填 Dockerfile 全路径，例如：

- `experimental/images/frameworks/sandbox/v1/Dockerfile`

## 建议

如果目标是“构建一个 framework runtime 并补齐依赖”，推荐：

- `target=runtime/fw/<framework>/<version>`
- `profile=full`

如果目标是“依赖都在，只重跑这一层”，推荐：

- `target=image/fw/<framework>/<version>` 或 `target=runtime/fw/<framework>/<version>`
- `profile=quick`

