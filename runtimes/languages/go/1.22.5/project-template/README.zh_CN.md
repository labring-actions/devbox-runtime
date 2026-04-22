# Go 1.22.5 运行时模板

该模板为 DevBox **Go 1.22.5** 运行时提供一个最小可运行的 HTTP 服务。

## 运行时概览

- 语言版本：`Go 1.22.5`
- 基础运行时镜像：`go-1.22.5`
- 启动脚本：`entrypoint.sh`
- 默认服务端口：`8080`

## 模板文件

- `main.go`：基于 `net/http` 的 HTTP 服务
- `entrypoint.sh`：支持模式切换的启动脚本

## 在 DevBox 中运行

以下命令在 `/home/devbox/project` 目录执行。

### 开发模式

```bash
bash entrypoint.sh
```

行为说明：
- 使用 `go run main.go`，便于快速迭代。

### 生产模式

```bash
bash entrypoint.sh production
```

行为说明：
- 先构建二进制：`go build -o hello_world main.go`
- 再运行二进制：`./hello_world`

## 验证服务

```bash
curl http://127.0.0.1:8080
```

预期输出：

```text
Hello, World!
```

## 自定义建议

- 在 `main.go` 中增加路由与处理逻辑。
- 项目变大后可迁移为标准 Go module 目录结构。
- 若修改二进制名称，请同步更新 `entrypoint.sh` 的构建目标。
