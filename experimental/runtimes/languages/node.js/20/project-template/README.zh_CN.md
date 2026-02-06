# Node.js 20 运行时模板

该模板为 DevBox **Node.js 20** 运行时提供一个最小可运行的 HTTP 服务。

## 运行时概览

- 语言版本：`Node.js 20`
- 基础运行时镜像：`node.js-20`
- 启动脚本：`entrypoint.sh`
- 默认服务端口：`8080`

## 模板文件

- `hello_world.js`：基于 Node 内置 `http` 模块的 HTTP 服务
- `entrypoint.sh`：可切换环境模式的启动脚本

## 在 DevBox 中运行

以下命令在 `/home/devbox/project` 目录执行。

### 开发模式

```bash
bash entrypoint.sh
```

行为说明：
- 以 `NODE_ENV=development node hello_world.js` 启动服务。

### 生产模式

```bash
bash entrypoint.sh production
```

行为说明：
- 以 `NODE_ENV=production node hello_world.js` 启动服务。

## 验证服务

```bash
curl http://127.0.0.1:8080
```

预期输出：

```text
Hello World!
```

## 自定义建议

- 可将 `hello_world.js` 替换为实际应用入口（Express/Fastify/Nest 等）。
- 若调整启动命令，请同步修改 `entrypoint.sh`。
- 迁移为依赖化项目后，补充依赖安装与构建步骤。
