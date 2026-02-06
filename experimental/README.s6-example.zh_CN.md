# Runtime README 示例（基于 s6-overlay）

> 该示例用于 `experimental/runtimes/*` 下的运行时模板文档。
> 依据 `experimental/base-tools` 的构建与服务编排逻辑编写。

## 1. 运行模型

本运行时基于 **s6-overlay v3** 启动，容器入口为：

```dockerfile
ENTRYPOINT ["/init"]
```

在基础 OS 镜像构建阶段，会通过 `base-tools` 执行：

- `install-s6.sh`：安装 s6-overlay
- `configure-svc.sh`：生成/配置 s6 服务定义
- Dockerfile 设置 `S6_STAGE2_HOOK=/etc/s6-overlay-hook/pre-rc-init.d/pre-rc-init.sh`

对应文件：

- `experimental/images/operating-systems/*/*/Dockerfile`
- `experimental/images/operating-systems/*/*/build.sh`
- `experimental/base-tools/scripts/configure-svc.sh`

## 2. 启动顺序（关键）

启动链路如下：

1. `/init` 启动 s6-overlay。
2. 执行 `S6_STAGE2_HOOK`（`pre-rc-init.sh`），在 **s6-rc compile 前** 根据 `DEVBOX_ENV` 启用/禁用服务。
3. s6-rc 编译服务清单。
4. 启动已启用服务。

`pre-rc-init.sh` 会读取 `services.conf`，并通过以下方式禁用服务：

- 从 `/etc/s6-overlay/s6-rc.d/user/contents.d/<service>` 移除
- 删除 `/etc/s6-overlay/s6-rc.d/<service>` 服务定义目录

## 3. 默认服务与环境差异

`services.conf`（来自 `experimental/base-tools/scripts/svc/services.conf`）默认配置：

| 服务 | development | production | 说明 |
|---|---:|---:|---|
| `startup` | 1 | 1 | 执行 `/usr/start` 下启动脚本 |
| `entrypoint` | 1 | 1 | 运行项目 `entrypoint.sh` |
| `crond` / `crond-log` | 1 | 1 | cron 任务与日志 |
| `sshd` / `sshd-log` | 1 | 0 | 仅开发环境开启 |

补充：

- `sdk-server` 在配置阶段会注册 s6 服务，但运行时还会判断：
  - 仅当 `DEVBOX_JWT_SECRET` 非空且 `DEVBOX_ENV != production` 才真正启动。

## 4. 项目约定（面向 runtime 使用者）

### 4.1 `entrypoint.sh`

项目目录约定：`/home/devbox/project/entrypoint.sh`

`entrypoint` s6 服务会以 `devbox` 用户执行：

```bash
./entrypoint.sh "${DEVBOX_ENV:-development}"
```

建议约定：

- 第一个参数接收运行环境（`development` / `production`）。
- 脚本内部根据参数切换启动逻辑。
- 若脚本不存在，系统会记录日志并跳过，不会导致容器启动失败。

### 4.2 启动脚本目录 `/usr/start`

`startup` oneshot 服务会按文件名字典序执行 `/usr/start` 下可执行脚本。

要求：

- 启动脚本应快速退出，不应阻塞。
- 失败会中断 startup 阶段并返回错误。

## 5. 自定义 s6 服务（示例）

若运行时需要额外托管 `my-app` 长驻进程，可在镜像构建时创建：

```bash
# 1) 服务目录
mkdir -p /etc/s6-overlay/s6-rc.d/my-app/dependencies.d

# 2) 服务类型
printf 'longrun\n' > /etc/s6-overlay/s6-rc.d/my-app/type

# 3) run 脚本
cat >/etc/s6-overlay/s6-rc.d/my-app/run <<'RUN'
#!/command/with-contenv bash
set -euo pipefail
cd /home/devbox/project
exec ./my-app
RUN
chmod 700 /etc/s6-overlay/s6-rc.d/my-app/run

# 4) 声明依赖（可选）
: > /etc/s6-overlay/s6-rc.d/my-app/dependencies.d/startup

# 5) 加入 user bundle
: > /etc/s6-overlay/s6-rc.d/user/contents.d/my-app
```

若希望按环境开关该服务，请同步更新 hook 中使用的 `services.conf`。

## 6. README 可复用片段

可在各 runtime README 里直接放入如下说明：

> This runtime is managed by s6-overlay. Container entrypoint is `/init`, and project `/home/devbox/project/entrypoint.sh` is executed by the `entrypoint` s6 service with `${DEVBOX_ENV}` as the first argument. Service enablement differs by environment via `S6_STAGE2_HOOK` + `services.conf` before s6-rc compilation.

## 7. 排查命令

```bash
# 查看 s6 服务定义
ls -la /etc/s6-overlay/s6-rc.d

# 查看 user bundle 中已启用服务
ls -la /etc/s6-overlay/s6-rc.d/user/contents.d

# 查看环境
echo "$DEVBOX_ENV"

# 查看 startup/entrypoint 脚本
ls -la /usr/start
ls -la /home/devbox/project/entrypoint.sh
```
