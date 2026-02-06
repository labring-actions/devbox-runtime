# Rust 1.81.0 运行时模板

该模板为 DevBox **Rust 1.81.0** 运行时提供一个基于 Actix Web 的最小 HTTP 服务。

## 运行时概览

- 语言版本：`Rust 1.81.0`
- 基础运行时镜像：`rust-1.81.0`
- 启动脚本：`entrypoint.sh`
- 默认服务端口：`8080`

## 模板文件

- `Cargo.toml` / `Cargo.lock`：项目与依赖配置
- `src/main.rs`：Actix Web 服务入口
- `entrypoint.sh`：开发/生产模式启动逻辑

## 在 DevBox 中运行

以下命令在 `/home/devbox/project` 目录执行。

### 开发模式

```bash
bash entrypoint.sh
```

行为说明：
- 使用 `cargo run` 启动。

### 生产模式

```bash
bash entrypoint.sh production
```

行为说明：
- 先构建 release 二进制：`cargo build --release --bin hello_world`
- 再运行：`./target/release/hello_world`

## 验证服务

```bash
curl http://127.0.0.1:8080
```

预期输出：

```text
Hello, World!
```

## 自定义建议

- 在 `src/main.rs` 中扩展路由和中间件。
- 在 `Cargo.toml` 中新增依赖。
- 若修改可执行目标名，请同步更新 `entrypoint.sh` 与 `Cargo.toml`。
