# 简单 WEB 后端框架

仓库地址：[simple-web](https://github.com/HUAHUAI23/simple-web)

一个轻量级的 **函数编程式 Web 服务框架**，支持 **函数式** 编写后端接口，内置 WebSocket、XML 解析、CORS 等特性，方便 **小程序，函数计算，腾讯云开发用户** 快速进行后端服务开发。方便集成到各种公有云平台，容器平台，进行各种 **插件式开发，敏捷开发**。

- [sealos 操作系统 公有云环境](https://gzg.sealos.run)
- [sealos devbox 快速开发](https://gzg.sealos.run/?openapp=system-devbox)
- [sealos 云开发](https://gzg.sealos.run/?openapp=system-sealaf)

## 🌟 核心特性

- **零配置开发** - 快速启动项目，无需繁琐配置
- **自动路由生成** - 基于文件系统的路由组织方式
- **函数式编程** - 直观的接口编写方式
- **丰富的内置功能**
  - WebSocket 支持
  - XML 解析能力
  - CORS 配置
  - 函数缓存
  - 可配置日志级别
  - Express.js 扩展能力

## 🚀 快速开始

> 第一个 hello world 接口

### 环境要求

- Node.js >= 22.0.0
- pnpm（推荐的包管理工具）

### 安装

`package.json`:

```json
{
  "name": "simple-web",
  "version": "1.0.0",
  "description": "",
  "main": "dist/index.js",
  "module": "dist/index.js",
  "types": "dist/index.d.ts",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1",
    "dev": "nodemon --exec tsx watch index.ts",
    "build": "tsc",
    "start": "node dist/index.js",
    "clean": "rimraf dist",
    "build:clean": "pnpm clean && pnpm build",
    "typecheck": "tsc --noEmit",
    "start:prod": "cross-env NODE_ENV=production node dist/index.js"
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "devDependencies": {
    "@types/node": "^22.8.1",
    "nodemon": "^3.1.7",
    "rimraf": "^6.0.1",
    "tslib": "^2.8.0",
    "tsx": "^4.19.1",
    "typescript": "^5.6.3"
  },
  "dependencies": {
    "simple-web23": "^0.0.25"
  }
}
```

tsconfig.json:

```json
{
    "compileOnSave": true,
    "compilerOptions": {
        "target": "ESNext",
        "module": "NodeNext",
        "moduleResolution": "NodeNext",
        "moduleDetection": "auto",
        "removeComments": true,
        "lib": [
            "ESNext"
        ],
        "outDir": "dist",
        "rootDir": ".",
        "baseUrl": ".",
        "strict": true,
        "esModuleInterop": true,
        "skipLibCheck": true,
        "forceConsistentCasingInFileNames": true,
        "importHelpers": true,
        "composite": true,
    },
    "include": [
        "**/*",
    ],
    "exclude": [
        "node_modules",
        "dist"
    ]
}
```

`nodemon.json`:

```json
{
    "watch": [
        "functions/",
        ".env"
    ],
    "ignore": [
        "*.test.js",
        "*.spec.js",
        "*.test.ts",
        "*.spec.ts",
        "node_modules/",
        "dist"
    ],
    "ext": "ts,js,json,yaml,yml",
    "exec": "tsx watch index.ts",
    "delay": "1000",
    "env": {
        "NODE_ENV": "development"
    }
}
```

下面的示例，项目根目录均为 `demo` 在项目根目录下添加上面三个文件 package.json 、tsconfig.json 和 nodemon.json，然后执行 `pnpm install simple-web` 安装依赖, 如果没有安装 pnpm 请先安装 pnpm，`npm install -g pnpm`

项目结构示例

```plain
demo
├── index.ts
├── package.json
├── tsconfig.json
├── nodemon.json
```

### 使用

下面给出入口文件为 `index.ts` ，在 `index.ts` 中引入 SimpleWeb 并启动服务的示例。

`demo/index.ts`

```typescript
import { SimpleWeb, SimpleWebConfig } from 'simple-web23'

const config: SimpleWebConfig = {
    port: 3000,
    logLevel: 'debug',
    isProd: process.env.NODE_ENV === 'production',
    requestLimitSize: '100mb'
}

const app = new SimpleWeb(config)
app.start()
```

启动项目，在项目根目录下执行 `pnpm dev`

默认服务监听端口为 `2342`，默认在根目录中生成 `functions` 目录，所有 **接口函数** 必须都写在这个目录下，只有该目录下的函数才会被注册为路由。

simple web 框架的路由组织方式为文件系统组织方式，例如 `functions/hello.ts` 对应的路由为 `/hello` ，`functions/user/info.ts` 对应的路由为 `/user/info`

访问每个接口时，默认执行 `default` 函数，因此需要定义默认导出函数 `export default async function` 或者 `export default function`

开始第一个 hello 接口

`functions/hello.ts`

```typescript
import type { FunctionContext } from 'simple-web23'

export default async function (ctx: FunctionContext) {
    return {
        data: 'hello'
    }
}
```

```plain
demo
├── functions
│   ├── hello.ts
├── index.ts
├── package.json
├── tsconfig.json
├── nodemon.json
```

在项目根目录运行项目，`pnpm dev` 后,访问 `http://localhost:2342/hello`， 可以利用 curl 工具模拟访问 `curl http://localhost:2342/hello`，可以看到数据返回

```json
{
    "data": "hello world"
}
```

### 📚进阶指南

simple web 框架使用 mongo 数据库，s3 对象存储，请看 [跳到更多示例](#更多示例)
获取 simple web 框架的函数上下文，配置项，请看 [跳到函数上下文](#simple-web-框架函数上下文)

## simple web 框架函数上下文

接口函数的默认导出函数为 `default` 函数，`default` 函数接收一个 `FunctionContext` 参数，`FunctionContext` 为 simple web 框架的函数上下文，包含以下属性：

### FunctionContext 属性说明

- `files`: 上传文件信息
  - 类型: `{ [fieldname: string]: Express.Multer.File[] } | Express.Multer.File[] | undefined`
  - 说明: 包含通过表单上传的文件信息

- `headers`: 请求头信息
  - 类型: `Request['headers']`
  - 说明: HTTP 请求头部信息

- `query`: URL 查询参数
  - 类型: `Request['query']`
  - 说明: URL 中的查询字符串参数

- `body`: 请求体数据
  - 类型: `Request['body']`
  - 说明: HTTP 请求体中的数据

- `params`: 路由参数
  - 类型: `Request['params']`
  - 说明: URL 路径中的动态参数

- `method`: 请求方法
  - 类型: `Request['method']`
  - 说明: HTTP 请求方法（GET、POST 等）

- `webSocket`: WebSocket 连接对象
  - 类型: `WebSocket`
  - 说明: WebSocket 连接实例（仅在 WebSocket 连接时可用）

- `request`: 原始请求对象
  - 类型: `Request`
  - 说明: Express 原始请求对象

- `response`: 原始响应对象
  - 类型: `Response`
  - 说明: Express 原始响应对象

- `__function_name`: 函数名称
  - 类型: `string`
  - 说明: 当前执行的函数名称

- `requestId`: 请求 ID
  - 类型: `string`
  - 说明: 用于追踪请求的唯一标识符

- `url`: 请求 URL
  - 类型: `string`
  - 说明: 完整的请求 URL

#### 使用示例 FunctionContext 示例

```typescript
import type { FunctionContext } from 'simple-web23'

export default async function (ctx: FunctionContext) {
    // 获取查询参数
    const { name } = ctx.query

    // 获取请求头
    const userAgent = ctx.headers['user-agent']

    // 获取请求体数据
    const { data } = ctx.body

    return {
        name,
        userAgent,
        data,
        requestId: ctx.requestId
    }
}
```

#### 使用原始 Response 对象示例

如果需要更细粒度的控制响应，可以直接使用 `ctx.response` 对象：

```typescript
import type { FunctionContext } from 'simple-web23'

export default async function (ctx: FunctionContext) {
    // 使用原始 response 对象设置状态码和发送响应
    ctx.response
        .status(201)
        .send({
            message: 'Created successfully',
            timestamp: new Date().toISOString()
        })
}
```

这种方式让你可以：

- 直接设置 HTTP 状态码
- 自定义响应头
- 控制响应格式
- 流式传输数据
- 使用其他 Express Response 对象的方法

### 接口函数全局上下文

```typescript
export interface FunctionModuleGlobalContext {
    __filename: string;
    module: Module;
    exports: Module['exports'];
    console: Console;
    __require: typeof FunctionModule.functionsImport;
    RegExp: typeof RegExp;
    Buffer: typeof Buffer;
    Float32Array: typeof Float32Array;
    setInterval: typeof setInterval;
    clearInterval: typeof clearInterval;
    setTimeout: typeof setTimeout;
    clearTimeout: typeof clearTimeout;
    setImmediate: typeof setImmediate;
    clearImmediate: typeof clearImmediate;
    Promise: typeof Promise;
    process: typeof process;
    URL: typeof URL;
    fetch: typeof fetch;
    global: unknown;
    __from_modules: string[];
}
```

```typescript
import type { FunctionModuleGlobalContext } from 'simple-web23'
```

接口函数的全局上下文可以通过 `global` 对象访问，例如 `global.__filename` 可以获取当前接口函数文件路径

## simple web 框架配置项

### 配置项

```typescript
import type { SimpleWebConfig } from 'simple-web23'
import { Config } from 'simple-web23'
```

SimpleWeb 框架支持以下配置选项：

| 配置项 | 类型 | 默认值 | 说明 |
|--------|------|---------|------|
| port | number | 2342 | 服务器监听端口 |
| logLevel | 'debug' \| 'info' \| 'warn' \| 'error' | 'info' | 日志输出级别 |
| displayLineLogLevel | 'debug' \| 'info' \| 'warn' \| 'error' | 'info' | 显示行号的日志级别 |
| logDepth | number | 4 | 日志对象递归深度 |
| requestLimitSize | string | '50mb' | 请求体大小限制 |
| disableModuleCache | boolean | false | 是否禁用模块缓存 |
| isProd | boolean | false | 是否为生产环境 |
| workspacePath | string | \`${process.cwd()}/functions\` | 接口函数目录 |

#### 使用配置项示例

```typescript
import { SimpleWeb, SimpleWebConfig } from 'simple-web23'

const config: SimpleWebConfig = {
    port: 3000,
    logLevel: 'debug',
    isProd: process.env.NODE_ENV === 'production',
    requestLimitSize: '100mb'
}

const app = new SimpleWeb(config)
app.start()
```

### 工具函数

simple web 框架提供 `FunctionCache` `FunctionModule` `FunctionExecutor` 三个工具函数

```typescript
import { FunctionCache, FunctionModule, FunctionExecutor } from 'simple-web23'
```

使用 `FunctionCache` 可以获取当前所有的接口函数的原始代码缓存

```typescript
import type { FunctionContext } from 'simple-web23'
export default async function (ctx: FunctionContext) {
    const cache = FunctionCache.getAll()
    console.log(cache)
}
```

使用 `FunctionModule` 可以获取当前所有的接口函数模块

```typescript
import type { FunctionContext } from 'simple-web23'
export default async function (ctx: FunctionContext) {
    const modules = FunctionModule.getCache()
    console.log(modules)
}
```

## 更多示例

大部分 web 开发中都需要用到 **数据库** **对象存储** 这些东西, 下面给出使用 mongo 数据库 和 S3 对象存储的示例。

simple web 框架支持在接口函数目录外写一些 持久化的 client，例如 数据库 client，s3 对象存储 client 等和一些 corn job 等，推荐将这些 client 和 cron job 写在接口函数目录外。

### 使用 mongo 数据库

在项目根目录执行 `pnpm install mongodb` 安装 mongodb 客户端，在 `client` 目录下创建 `mongo.ts` 文件，写入 mongodb 客户端代码。

```typescript
import { MongoClient } from 'mongodb'

// 生产环境切记将密码和用户 替换成从环境变量中获取，切记不要在代码中写死泄露密码
// const username = process.env.MONGO_USERNAME
// const password = process.env.MONGO_PASSWORD
// const uri = `mongodb://${username}:${password}@test-mongodb.ns-1k9qk3v6.svc:27017`
const uri = "mongodb://root:tf44dbrn@dbconn.sealosgzg.site:45222/?directConnection=true"



// 创建 MongoDB 客户端实例
export const client = new MongoClient(uri)
```

在 `functions` 目录下创建 `mongo-test.ts` 文件，写入 mongodb 测试代码。

```typescript
import { FunctionContext } from 'simple-web23'
import { client } from '../client/mongo'

export default async function (ctx: FunctionContext) {
    const database = client.db('test')
    const collection = database.collection('test')

    // 创建测试数据
    console.log('--- 创建测试数据 ---')
    const insertResult = await collection.insertMany([
        { name: '张三', age: 25, city: '北京' },
        { name: '李四', age: 30, city: '上海' }
    ])
    console.log('插入数据结果:', insertResult)

    // 查询所有数据
    console.log('\n--- 查询所有数据 ---')
    const allDocs = await collection.find({}).toArray()
    console.log('所有数据:', allDocs)

    // 查询单个数据
    console.log('\n--- 查询单个数据 ---')
    const oneDoc = await collection.findOne({ name: '张三' })
    console.log('查询张三的数据:', oneDoc)

    // 更新数据
    console.log('\n--- 更新数据 ---')
    const updateResult = await collection.updateOne(
        { name: '张三' },
        { $set: { age: 26, city: '深圳' } }
    )
    console.log('更新结果:', updateResult)

    // 查看更新后的数据
    const updatedDoc = await collection.findOne({ name: '张三' })
    console.log('更新后的张三数据:', updatedDoc)

    // 删除数据
    console.log('\n--- 删除数据 ---')
    const deleteResult = await collection.deleteOne({ name: '李四' })
    console.log('删除结果:', deleteResult)

    // 最终查询所有数据
    console.log('\n--- 最终数据 ---')
    const finalDocs = await collection.find({}).toArray()
    console.log('最终所有数据:', finalDocs)

    return { message: '测试完成' }
}
```

```plain
demo
├── functions
│   ├── hello.ts
│   ├── mongo-test.ts
├── client
│   ├── mongo.ts
├── index.ts
├── package.json
├── tsconfig.json
├── nodemon.json
```

### 使用 S3 对象存储

在项目根目录执行 `pnpm install @aws-sdk/client-s3` 安装 s3 客户端，在 `client` 目录下创建 `s3.ts` 文件，写入 s3 客户端代码。

```typescript
import { S3Client, ListObjectsV2Command, PutObjectCommand, _Object } from "@aws-sdk/client-s3"

// 创建 S3 客户端
// 生产环境切记将密码和用户 替换成从环境变量中获取，切记不要在代码中写死泄露密码
// const accessKeyId = process.env.S3_ACCESS_KEY_ID
// const secretAccessKey = process.env.S3_SECRET_ACCESS_KEY

const s3Client = new S3Client({
    region: "cn-north-1", // 例如 "ap-northeast-1"
    endpoint: "https://objectstorageapi.gzg.sealos.run", // 例如 "https://s3.amazonaws.com" 或自定义endpoint
    credentials: {
        accessKeyId: "xxxxxxxxxx",
        secretAccessKey: "xxxxxxxxxx"
    },
    // 如果使用自定义endpoint（比如MinIO），可能需要以下配置
    forcePathStyle: true, // 强制使用路径样式而不是虚拟主机样式
})

// 列出 bucket 中的文件
async function listFiles(bucketName: string) {
    try {
        const command = new ListObjectsV2Command({
            Bucket: bucketName,
        })

        const response = await s3Client.send(command)

        // 打印文件列表
        response.Contents?.forEach((file: _Object) => {
            console.log(`文件名: ${file.Key}, 大小: ${file.Size} bytes`)
        })

        return response.Contents
    } catch (error) {
        console.error("列出文件失败:", error)
        throw error
    }
}

// 上传文件到 S3
async function uploadFile(bucketName: string, key: string, fileContent: Buffer) {
    try {
        const command = new PutObjectCommand({
            Bucket: bucketName,
            Key: key,
            Body: fileContent,
        })

        const response = await s3Client.send(command)
        console.log("文件上传成功:", response)
        return response
    } catch (error) {
        console.error("文件上传失败:", error)
        throw error
    }
}

export { listFiles, uploadFile }
```

在 `functions` 目录下创建 `s3-test.ts` 文件，写入 s3 测试代码。

```typescript
import { FunctionContext } from 'simple-web23'
import { listFiles, uploadFile } from '../client/s3'



export default async function (ctx: FunctionContext) {
    const bucketName = '1k9qk3v6-test2'
    const fileName = 'test.txt'
    const fileContent = Buffer.from('Hello World')
    await uploadFile(bucketName, fileName, fileContent)
    await listFiles(bucketName)
    return 'success'
}
```

## 🎯 未来规划

- [ ] 插件系统支持
- [ ] 全局上下文定义
- [ ] 生命周期钩子
- [ ] Path 路由增强
- [ ] OpenAPI 集成
- [ ] 多语言支持 (Python/Go/Java)

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request。
