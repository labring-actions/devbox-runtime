# Java OpenJDK 17 运行时模板

该模板为 DevBox **OpenJDK 17** 运行时提供一个最小可运行的 Java HTTP 服务。

## 运行时概览

- 语言/运行时版本：`OpenJDK 17`
- 基础运行时镜像：`java-openjdk17`
- 启动脚本：`entrypoint.sh`
- 默认服务端口：`8080`

## 模板文件

- `HelloWorld.java`：基于 `com.sun.net.httpserver` 的 HTTP 服务
- `entrypoint.sh`：开发/生产模式通用的编译运行脚本

## 在 DevBox 中运行

以下命令在 `/home/devbox/project` 目录执行。

### 开发模式

```bash
bash entrypoint.sh
```

行为说明：
- 先执行 `javac HelloWorld.java` 编译
- 再执行 `java HelloWorld` 运行

### 生产模式

```bash
bash entrypoint.sh production
```

行为说明：
- 与开发模式保持一致，使用同一编译运行流程，保证执行路径确定。

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
- 需要依赖管理时可引入 Maven/Gradle。
- 切换为 fat-jar 或框架启动后，请同步更新 `entrypoint.sh`。
