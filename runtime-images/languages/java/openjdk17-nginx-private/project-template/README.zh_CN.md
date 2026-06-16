# JDK 17 + Nginx 私有化运行时模板

该模板面向私有化部署场景，提供 **OpenJDK 17** 应用运行环境，并使用 **Nginx 1.22.1** 作为前置 HTTP 入口。

## 运行时概览

- 语言/运行时版本：`OpenJDK 17`
- Web 入口：`Nginx 1.22.1`
- 基础运行时镜像：`java-openjdk17-nginx-private`
- 启动脚本：`entrypoint.sh`
- 默认对外服务端口：`8080`
- 默认 Java 应用端口：`18080`（仅监听 `127.0.0.1`）

## 模板文件

- `HelloWorld.java`：基于 `com.sun.net.httpserver` 的 Java HTTP 服务
- `nginx.conf`：项目级 Nginx server 配置，将 `8080` 转发到 Java 应用
- `entrypoint.sh`：编译 Java 应用、启动后端进程并以前台模式启动 Nginx

## 在 DevBox 中运行

以下命令在 `/home/devbox/project` 目录执行。

### 开发模式

```bash
bash entrypoint.sh
```

行为说明：
- 执行 `javac HelloWorld.java` 编译应用。
- 在 `127.0.0.1:18080` 启动 Java 服务。
- 校验 Nginx 配置后，在 `0.0.0.0:8080` 启动 Nginx。

### 生产模式

```bash
bash entrypoint.sh production
```

行为说明：
- 与开发模式使用同一启动路径，便于私有化环境保持入口一致。

## 验证服务

```bash
curl http://127.0.0.1:8080
```

预期输出：

```text
Hello from JDK 17 behind Nginx
```

## 自定义建议

- 将 `HelloWorld.java` 替换为实际业务应用或框架入口。
- 如需调整后端端口，可同步修改 `JAVA_APP_PORT` 和 `nginx.conf` 的 `proxy_pass`。
- 可在 `nginx.conf` 中增加 TLS 终止、反向代理、缓存、静态资源或私有化部署所需的路由规则。
