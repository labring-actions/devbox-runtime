# Nginx 1.22.1 运行时模板

该模板提供一个基于 **Nginx 1.22.1** 的静态站点运行时。

## 运行时概览

- 框架/运行时版本：`Nginx 1.22.1`
- 基础运行时镜像：`nginx-1.22.1`
- 启动脚本：`entrypoint.sh`
- 默认服务端口：`8080`（由项目内 `nginx.conf` 配置）

## 模板文件

- `index.html`：默认静态首页
- `nginx.conf`：项目级 server 配置（监听 `8080`）
- `entrypoint.sh`：校验配置并以前台模式启动 nginx

## 在 DevBox 中运行

以下命令在 `/home/devbox/project` 目录执行。

### 启动服务

```bash
bash entrypoint.sh
```

行为说明：
- 先执行 `nginx -t` 校验配置。
- 再以 `daemon off` 前台模式启动 Nginx。

### 生产模式参数

```bash
bash entrypoint.sh production
```

行为说明：
- 当前脚本行为与开发模式一致，多余参数会被忽略。

## 验证服务

```bash
curl http://127.0.0.1:8080
```

## 自定义建议

- 修改 `index.html` 以承载静态页面内容。
- 在 `nginx.conf` 中增加反向代理、缓存、压缩或路由规则。
- 保持 `nginx.conf` 监听端口与容器暴露端口一致。
