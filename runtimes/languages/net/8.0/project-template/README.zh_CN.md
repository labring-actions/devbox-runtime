# .NET 8.0 运行时模板

该模板为 DevBox **.NET 8.0** 运行时提供一个最小可运行的 ASP.NET Core 服务。

## 运行时概览

- 语言/运行时版本：`.NET 8.0`
- 基础运行时镜像：`net-8.0`
- 启动脚本：`entrypoint.sh`
- 默认服务端口：`8080`

## 模板文件

- `Program.cs`：最小化 API 应用入口
- `hello_world.csproj`：项目定义文件
- `entrypoint.sh`：开发/生产模式启动逻辑
- `hello_world.http`：本地调试请求示例

## 在 DevBox 中运行

以下命令在 `/home/devbox/project` 目录执行。

### 开发模式

```bash
bash entrypoint.sh
```

行为说明：
- 使用 `dotnet run` 启动服务。

### 生产模式

```bash
bash entrypoint.sh production
```

行为说明：
- 先以 Release 模式发布：`dotnet publish -c Release`
- 再运行发布产物：`dotnet ./bin/Release/net8.0/publish/hello_world.dll`

## 验证服务

```bash
curl http://127.0.0.1:8080
```

预期输出：

```text
Hello, World
```

## 自定义建议

- 在 `Program.cs` 中扩展路由和服务。
- 在 `hello_world.csproj` 中维护依赖与构建配置。
- 若目标框架或输出路径变化，请同步更新 `entrypoint.sh`。
