# 从基础镜像创建 Devbox Runtime

这是一份给 LLM 或维护者执行的精简手册。目标是把一个已有镜像转换成符合 Devbox 约定的 runtime，而不是记录某次排障过程。

## 输入信息

创建新 runtime 前先明确这些信息：

- 基础镜像：例如 `openanolis/anolisos:23.4`、`macrosan/kylin:v10-sp3`
- Runtime 路径：例如 `operating-systems/anolis/23.4`
- Runtime 名称和版本：例如 `anolis` + `23.4`
- 包管理器族：`apt`、`dnf`、`yum` 或其它
- 支持架构：至少确认 `amd64`，如需 `arm64` 要验证基础镜像和外部包都有对应架构
- 本地化：默认 `en_US`，需要时支持 `zh_CN`

## 必须生成的文件

以 `operating-systems/<name>/<version>` 为例，通常需要新增：

- `base-images/operating-systems/<name>/<version>/Dockerfile`
- `base-images/operating-systems/<name>/<version>/build.sh`
- `runtime-images/operating-systems/<name>/<version>/Dockerfile`
- `runtime-images/operating-systems/<name>/<version>/build.sh`
- `runtime-images/operating-systems/<name>/<version>/project-template/README.en_US.md`
- `runtime-images/operating-systems/<name>/<version>/project-template/README.zh_CN.md`
- `runtime-images/operating-systems/<name>/<version>/project-template/entrypoint.sh`
- `tests/runtime-smoke/operating-systems/<name>/<version>/smoke.sh`

同时注册到：

- `tests/runtime-conformance/run.sh`
- `tests/runtime-conformance/README.md`

## Base Image 转换步骤

Base image 负责把原始系统镜像变成 Devbox 可运行基础层。

`Dockerfile` 应遵循现有 OS runtime 模式：

- 从 `tooling` stage 复制 `${BASE_TOOLS_DIR}` 到目标镜像
- 设置 `BASE_TOOLS_DIR`、`L10N`、`ARCH`、`DEFAULT_DEVBOX_USER`、`PROJECT_DIR`
- 设置 `S6_STAGE2_HOOK=/etc/s6-overlay-hook/pre-rc-init.d/pre-rc-init.sh`
- 设置 `S6_KILL_GRACETIME`
- 执行本目录的 `build.sh`
- 最终 `ENTRYPOINT ["/init"]`

`build.sh` 必须完成：

- 安装基础包
- 安装 cron、s6、SDK server
- 配置 s6 服务
- 配置 logrotate、login、locale、timezone
- 创建默认 `devbox` 用户
- 安装 `/usr/share/devbox/docs` 文档
- 清理包缓存和临时文件

基础包至少应覆盖：

- shell 和工具：`bash`、`busybox`、`coreutils/findutils/diffutils` 等同类包
- 网络和下载：`curl`、`wget`、`ca-certificates`
- 压缩和归档：`tar`、`gzip`、`xz`
- 用户和权限：`sudo`、`shadow/passwd`
- 进程和网络诊断：`procps`、`iproute`、`util-linux`
- SSH：`openssh-server`、`openssh-clients`
- 日志和定时任务：`logrotate`、`cron/cronie`
- VCS：`git`

如果是 RPM 系统，优先复用或扩展 `tooling/scripts/install-base-pkg-rpm.sh`；如果是 Debian/Ubuntu 系统，优先复用或扩展已有 deb 安装脚本。

## Runtime Image 转换步骤

Runtime image 负责把 base image 包装成用户真正进入的工作空间。

Runtime `Dockerfile` 应：

- 从对应 base image 构建
- 保留 `L10N`、`DEFAULT_DEVBOX_USER` 等参数
- 设置工作目录为 `/home/devbox/project`
- 复制 `project-template` 到项目目录
- 执行 runtime 层 `build.sh`

Runtime `build.sh` 应：

- 创建 `/home/devbox/project`
- 复制 README 和 `entrypoint.sh`
- 设置 `entrypoint.sh` 可执行
- 将项目目录所有权交给默认 `devbox` 用户
- 避免把 root 生成的缓存或构建产物留给 devbox 用户不可写

`project-template/entrypoint.sh` 应：

- 支持 root 启动后切换到 `devbox` 用户执行
- 默认在 `/home/devbox/project` 下运行
- 保持前台进程存活，避免容器启动后立即退出

## SSH 必须满足的条件

Devbox runtime 需要能被 VS Code Remote、SDK server 和平台侧 SSH 入口稳定连接。创建新 runtime 时必须检查这些点：

- `sshd` 能启动并监听 `0.0.0.0:22`
- 镜像构建阶段不依赖固定 host key；启动时如果缺少 `/etc/ssh/ssh_host_*_key`，必须执行 `ssh-keygen -A`
- `AuthorizedKeysFile` 必须指向平台注入路径：`/usr/start/.ssh/authorized_keys`
- 如果基础镜像已有 `AuthorizedKeysFile .ssh/authorized_keys`，必须替换旧配置，不能只在文件末尾追加
- `PasswordAuthentication no`
- `PubKeyAuthentication yes`
- `PermitRootLogin prohibit-password`
- `PermitEmptyPasswords no`
- `AllowTcpForwarding yes`
- 启动 `sshd` 前清理 `/run/nologin` 和 `/etc/nologin`，否则 `pam_nologin` 会拒绝非 root 用户登录

配置 `sshd_config` 时要用“按 key 替换”的方式，匹配空格和 tab：

```bash
grep -Eq "^[[:space:]]*$key[[:space:]]+"
sed -i -E "s|^[[:space:]]*$key[[:space:]]+.*|$key $value|"
```

## VS Code Remote 必须满足的条件

VS Code Server 对 Linux 运行库有最低要求。新 runtime 必须验证：

- `glibc >= 2.28`
- `/usr/lib64/libstdc++.so.6` 或对应系统路径包含 `GLIBCXX_3.4.25`
- `bash`、`tar`、`curl` 或 `wget` 可用

如果基础镜像 glibc 不满足，通常不建议硬升级 glibc，应更换基础镜像。

如果 glibc 满足但 libstdc++ 过旧，可以安装兼容的新 libstdc++，但必须：

- 不升级 glibc
- 固定下载来源
- 固定 sha256
- 同时处理 `amd64` 和 `arm64`
- 构建时立即校验 `GLIBCXX_3.4.25`

## Smoke Test 必查项

每个新 runtime 的 smoke test 至少检查：

- `/etc/os-release` 符合目标系统
- `devbox` 用户存在
- `/home/devbox/project` 存在
- README 和 `entrypoint.sh` 存在
- 基础命令可用：`bash`、`busybox`、包管理器、`curl/wget`、`git`
- `/usr/sbin/sshd` 存在
- `sshd -T` 中 `allowtcpforwarding yes`
- `/run/nologin` 和 `/etc/nologin` 不存在
- VS Code Remote 前置条件：glibc 和 libstdc++
- `entrypoint.sh` 能启动并保持运行

## Conformance 注册

新增 runtime 后必须注册到 conformance：

- 在 `tests/runtime-conformance/run.sh` 中加入 runtime 路径
- 在 `tests/runtime-conformance/README.md` 中说明检查范围

如果是语言或框架 runtime，还要添加对应语言版本、包管理器、模板启动、镜像源配置等专项检查。

## 常见基础镜像坑

只保留需要优先排查的关键坑：

- SSH host key 缺失：`sshd` 日志出现 `no hostkeys available`
- `AuthorizedKeysFile` 已有旧配置：平台注入的 key 不生效
- `AllowTcpForwarding no`：VS Code Remote 报端口转发禁用
- `/run/nologin` 存在：非 root SSH 登录被 `pam_nologin` 拒绝
- libstdc++ 过旧：VS Code Server 报 Linux prerequisites 不满足
- locale 包名不同：`glibc-langpack-*`、`glibc-all-langpacks`、`langpacks-*` 在不同 RPM 系统里不一致
- 包管理器不可用或源不可用：构建前先验证 `dnf/yum/apt` 能安装基础包

## 最小验收

完成后至少执行：

```bash
bash -n <modified-scripts>
```

然后构建目标 base image 和 runtime image，运行 smoke/conformance。最终容器里确认：

```bash
id devbox
test -d /home/devbox/project
/usr/sbin/sshd -T | grep -qx 'allowtcpforwarding yes'
test ! -e /run/nologin
test ! -e /etc/nologin
ldd --version | head -n1
grep -ao 'GLIBCXX_3\.4\.25' /usr/lib64/libstdc++.so.6
```

如果 runtime 要给 VS Code Remote 使用，还应通过一次真实 SSH 连接验证：

```bash
ssh -T -D 0 <target-host> true
```

## 给 LLM 的执行提示词

可以把下面这段作为任务提示词使用：

```text
请基于基础镜像 <base-image> 创建 Devbox runtime，路径为 <runtime-path>。

要求：
1. 参考仓库里现有 OS runtime 的 Dockerfile/build.sh/project-template/smoke test 模式。
2. 创建 base image 和 runtime image 两层，不要把所有逻辑堆在 runtime 层。
3. 安装 Devbox 必需基础包，配置 s6、sshd、logrotate、login、locale、默认 devbox 用户和项目目录。
4. sshd 必须支持平台注入 authorized_keys、启动时生成 host key、启用 AllowTcpForwarding，并清理 /run/nologin 和 /etc/nologin。
5. 验证 VS Code Server 前置条件：glibc >= 2.28，libstdc++ 包含 GLIBCXX_3.4.25。
6. 添加 runtime smoke test，并注册到 runtime conformance。
7. 保持改动局部，不改无关 runtime。
8. 如果基础镜像某项前置条件不满足，优先用最小兼容修复；无法安全修复时说明原因。
```
