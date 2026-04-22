# PHP 8.2 运行时模板

该模板为 DevBox **PHP 8.2** 运行时提供一个最小可运行的 HTTP 服务。

## 运行时概览

- 语言版本：`PHP 8.2`
- 基础运行时镜像：`php-8.2`
- 启动脚本：`entrypoint.sh`
- 默认服务端口：`8080`

## 模板文件

- `hello_world.php`：示例响应脚本
- `entrypoint.sh`：按模式启动 PHP 内置 Web Server

## 在 DevBox 中运行

以下命令在 `/home/devbox/project` 目录执行。

### 开发模式

```bash
bash entrypoint.sh
```

行为说明：
- 执行 `php -S 0.0.0.0:8080 hello_world.php`
- 开启开发排障常用的错误日志参数。

### 生产模式

```bash
bash entrypoint.sh production
```

行为说明：
- 同样监听 `8080` 端口启动内置服务
- 额外启用 `opcache` 相关参数以模拟生产性能配置。

## 验证服务

```bash
curl http://127.0.0.1:8080
```

预期输出：

```text
Hello, World!
```

## 自定义建议

- 将 `hello_world.php` 替换为业务入口文件。
- 使用 Laravel/Symfony 等框架时，请同步调整 `entrypoint.sh` 启动命令。
- 根据场景完善 `entrypoint.sh` 中的 PHP ini 参数。
