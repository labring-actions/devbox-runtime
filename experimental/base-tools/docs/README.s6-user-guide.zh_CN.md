# S6 用户指南

## 1. 什么是 s6

`s6` 是一套轻量级的进程监督与服务管理工具集，常用于 Linux 服务编排。
`s6-overlay` 是它在容器场景中的封装，提供 `/init` 作为容器 PID 1，并补齐容器多进程管理能力。

在当前 Runtime 中，s6 主要解决：

- 信号转发与优雅退出
- 子进程回收（避免僵尸进程）
- 多服务启动顺序与依赖管理
- 长驻服务异常退出后的监督与重启

## 2. s6 纵览

| 组件/路径 | 作用 | 用户是否会改 |
|---|---|---|
| `/init` | 容器入口，启动 s6-overlay 生命周期 | 否（通常不改） |
| `/etc/s6-overlay/s6-rc.d/<service>` | 单个服务定义（`type`、`run`、`finish`、依赖） | 是（新增自定义服务时） |
| `/etc/s6-overlay/s6-rc.d/user/contents.d` | 用户服务清单，决定哪些服务会被编译进运行图 | 是 |
| `S6_STAGE2_HOOK` + `/etc/s6-overlay-hook/pre-rc-init.d/services.conf` | 在 s6-rc 编译前按环境开关服务 | 是（需要按环境切换时） |
| `/usr/start` | startup oneshot 阶段执行的一次性脚本目录 | 是（初始化逻辑） |
| `/home/devbox/project/entrypoint.sh` | 项目主入口，由 `entrypoint` 服务触发 | 是（应用启动） |

## 3. 先理解 3 个关键点

1. s6 服务定义目录：`/etc/s6-overlay/s6-rc.d`
2. 启用服务清单（user bundle）：`/etc/s6-overlay/s6-rc.d/user/contents.d`
3. s6-rc 编译发生在容器启动早期（`/init` 阶段）

这意味着：

- 你改了 s6 配置后，通常需要**重启容器/DevBox** 才会生效。
- `entrypoint.sh` 是由 `entrypoint` s6 服务触发的，它运行时已经过了 s6-rc 编译阶段。

## 4. 什么时候用哪种方式

- 只想启动你的主应用：改项目里的 `entrypoint.sh`
- 只想做一次性初始化：放到 `/usr/start`（startup 服务会按文件名顺序执行）
- 想托管一个可重启的常驻进程：新增一个 s6 `longrun` 服务

## 5. 快速示例：新增一个 `my-api` 常驻服务

以下命令可在容器中执行（`devbox` 用户默认有 sudo 权限）：

```bash
# 1) 建目录
sudo mkdir -p /etc/s6-overlay/s6-rc.d/my-api/dependencies.d

# 2) 声明类型为 longrun
printf 'longrun\n' | sudo tee /etc/s6-overlay/s6-rc.d/my-api/type >/dev/null

# 3) 写 run 脚本（示例：启动项目中的 my-api 二进制）
sudo tee /etc/s6-overlay/s6-rc.d/my-api/run >/dev/null <<'RUN'
#!/command/with-contenv bash
set -euo pipefail
cd /home/devbox/project
exec ./my-api
RUN
sudo chmod 700 /etc/s6-overlay/s6-rc.d/my-api/run

# 4) （可选）依赖 startup，确保 /usr/start 初始化先执行完
sudo touch /etc/s6-overlay/s6-rc.d/my-api/dependencies.d/startup

# 5) 加入 user bundle（不加这步不会被启动）
sudo touch /etc/s6-overlay/s6-rc.d/user/contents.d/my-api
```

完成后重启 DevBox/容器，再验证：

```bash
ls -la /etc/s6-overlay/s6-rc.d/my-api
ls -la /etc/s6-overlay/s6-rc.d/user/contents.d | grep my-api
ps -ef | grep my-api | grep -v grep
```

## 6. 按环境开关服务（development / production）

当前运行时通过 hook 在编译前读取：

- `/etc/s6-overlay-hook/pre-rc-init.d/services.conf`

格式：

```text
service_name|development_enable|production_enable
```

例如让 `my-api` 仅开发环境启动：

```text
my-api|1|0
```

注意：

- 修改 `services.conf` 后，也需要重启容器/DevBox 才会生效。
- 不在 `services.conf` 里的服务默认按“启用”处理（若已在 user bundle 中）。

## 7. 删除一个自定义服务

```bash
sudo rm -f /etc/s6-overlay/s6-rc.d/user/contents.d/my-api
sudo rm -rf /etc/s6-overlay/s6-rc.d/my-api
```

然后重启容器/DevBox。

## 8. 常见问题

### Q1: 我在 `entrypoint.sh` 里创建了 s6 服务，为什么这次没启动？

因为 s6-rc 编译早于 `entrypoint.sh` 执行。你在 `entrypoint.sh` 里新增的定义，要在**下一次重启**后才会进入编译结果。

### Q2: 我已经创建了服务目录，为什么没起？

常见原因：

- 忘记创建 `user/contents.d/<service>`
- `run` 没有执行权限（应为 700）
- `exec` 的目标程序不存在或没有权限

### Q3: 能不能只用 s6，不用 `entrypoint.sh`？

可以。你可以把应用主进程完全做成 longrun 服务，但请确保：

- 仍保留你需要的基础服务（如 startup、crond 等）
- 清楚 dev/prod 服务矩阵对行为的影响

## 9. 推荐实践

- 先用 `entrypoint.sh` 跑通，再逐步拆到独立 s6 longrun 服务。
- 每个 longrun 只负责一个主进程，`run` 脚本最后必须 `exec`。
- 尽量把一次性逻辑放到 `/usr/start`，不要塞进 longrun 的 `run`。
