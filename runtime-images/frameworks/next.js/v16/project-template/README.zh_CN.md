# Next.js v16 运行时模板

该模板提供一个基于 **Next.js 16** 的 React Web 应用运行时，使用 App Router 和 TypeScript。

## 运行时概览

- 框架/运行时版本：`Next.js 16`
- 基础运行时镜像：`next.js-v16`
- 启动脚本：`entrypoint.sh`
- 默认服务端口：`3000`

## 模板文件

- `app/layout.tsx`：根布局和页面元数据
- `app/page.tsx`：由 App Router 渲染的默认首页
- `app/globals.css`：应用共享样式
- `next.config.ts`：Next.js 配置
- `tsconfig.json`：TypeScript 编译配置
- `entrypoint.sh`：以开发或生产模式启动 Next.js

## 在 DevBox 中运行

以下命令在 `/home/devbox/project` 目录执行。

### 开发模式

```bash
bash entrypoint.sh
```

行为说明：
- 执行 `npm install` 确保依赖已安装。
- 以 `next dev` 启动，监听 `0.0.0.0:3000` 并支持热重载。

### 生产模式

```bash
bash entrypoint.sh production
```

行为说明：
- 安装生产构建所需依赖。
- 执行 `npm run build` 构建项目。
- 构建完成后裁剪开发依赖。
- 以 `next start` 启动，监听 `0.0.0.0:3000`。

## 验证服务

```bash
curl http://127.0.0.1:3000
```

## 自定义建议

- 修改 `app/page.tsx` 调整默认页面。
- 在 `app/` 下创建目录以添加路由。
- 修改 `app/globals.css` 调整全局样式。
- 修改 `next.config.ts` 配置图片域名、构建输出等框架选项。
