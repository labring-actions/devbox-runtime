# NestJS v11 运行时模板

该模板提供一个基于 **NestJS 11** 的服务端应用运行时，基于官方 [TypeScript starter](https://github.com/nestjs/typescript-starter) 项目。

## 运行时概览

- 框架/运行时版本：`NestJS 11`
- 基础运行时镜像：`nest.js-v11`
- 启动脚本：`entrypoint.sh`
- 默认服务端口：`3000`

## 模板文件

- `src/main.ts`：应用入口，监听 `3000` 端口
- `src/app.module.ts`：根模块
- `src/app.controller.ts`：根控制器，处理 `GET /` 路由
- `src/app.service.ts`：根服务，返回 "Hello World!"
- `entrypoint.sh`：以开发或生产模式启动 NestJS

## 在 DevBox 中运行

以下命令在 `/home/devbox/project` 目录执行。

### 开发模式

```bash
bash entrypoint.sh
```

行为说明：
- 执行 `npm install` 确保依赖已安装。
- 以 `nest start --watch` 启动，支持代码热重载。

### 生产模式

```bash
bash entrypoint.sh production
```

行为说明：
- 仅安装生产依赖。
- 执行 `npm run build` 构建项目。
- 以 `node dist/main` 启动应用。

## 验证服务

```bash
curl http://127.0.0.1:3000
```

## 自定义建议

- 在 `src/` 下添加新的模块、控制器和服务。
- 修改 `src/main.ts` 更改监听端口或添加全局中间件。
- 修改 `tsconfig.json` 调整 TypeScript 编译选项。
