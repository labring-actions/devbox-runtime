# Java OpenJDK 25 运行时模板

该模板为 DevBox **OpenJDK 25** 运行时提供一个最小可运行的 Java HTTP 服务。镜像使用 Eclipse Temurin OpenJDK `25.0.4.1+1` 和 Apache Maven `3.9.16`。

## 运行时概览

- 语言/运行时版本：`Eclipse Temurin OpenJDK 25.0.4.1+1`
- 构建工具：`Apache Maven 3.9.16`
- 基础运行时镜像：`java-openjdk25`
- 启动脚本：`entrypoint.sh`
- 默认服务端口：`8080`

## 模板文件

- `HelloWorld.java`：基于 `com.sun.net.httpserver` 的 HTTP 服务
- `entrypoint.sh`：开发和生产模式通用的编译运行脚本

## 在 DevBox 中运行

以下命令在 `/home/devbox/project` 目录执行。

### 开发模式

```bash
bash entrypoint.sh
```

### 生产模式

```bash
bash entrypoint.sh production
```

两种模式都会使用 JDK 25 编译应用，然后通过 `java HelloWorld` 启动服务。

## 验证服务

```bash
curl http://127.0.0.1:8080
```

预期输出：

```text
Hello, World!
```

## 自定义建议

- 项目变大后建议将 `HelloWorld.java` 迁移为 package 目录结构。
- 需要依赖管理时可直接使用镜像内置的 Maven。
- 切换为可执行 JAR 或框架应用后，请同步更新 `entrypoint.sh`。
