# Sealaf Web Application Framework Example

This is a modern function-based web application framework example built with Sealaf 1.0.0, providing a clean and powerful API development experience.

## Project Description

This project creates a lightweight function-programming web service framework showcasing Simple Web's file-system routing capabilities. The application uses a functional approach for writing backend APIs with zero configuration and automatic route generation. The server listens on port 2342 and provides a clean, intuitive API development experience. The framework supports WebSocket, XML parsing, CORS, and other features, making it suitable for rapid development of small applications, microservices, and cloud functions.

## Environment

This project runs on a Debian 12 system with Node.js and Sealaf 1.0.0, which is pre-configured in the Devbox environment. You don't need to worry about setting up Node.js, npm, or Sealaf dependencies yourself. The development environment includes all necessary tools for building and running Sealaf applications. If you need to make adjustments to match your specific requirements, you can modify the configuration files accordingly.

## Project Execution

**Development mode:** For normal development environment, simply enter Devbox and run `bash entrypoint.sh` in the terminal. This will start the Simple Web development server with hot-reload enabled.

**Production mode:** After release, the project will be automatically packaged into a Docker image and deployed according to the `entrypoint.sh` script with production parameters (run `bash entrypoint.sh production`). This will build an optimized production build and run the application.


DevBox: Code. Build. Deploy. We've Got the Rest.

With DevBox, you can focus entirely on writing great code while we handle the infrastructure, scaling, and deployment. Seamless development from start to production.






# Simple WEB Backend Framework

Repository: [simple-web](https://github.com/HUAHUAI23/simple-web)

A lightweight **function-programming Web service framework** that supports **functional** backend interface development with built-in features like WebSocket, XML parsing, CORS, etc. It enables rapid backend service development for **mini-programs, function computing, and cloud development users**. The framework easily integrates with various public cloud platforms and container platforms, supporting **plugin-based development and agile development**.

- [sealos operating system public cloud environment](https://gzg.sealos.run)
- [sealos devbox rapid development](https://gzg.sealos.run/?openapp=system-devbox)
- [sealos cloud development](https://gzg.sealos.run/?openapp=system-sealaf)

## 🌟 Core Features

- **Zero Configuration Development** - Quick project startup without complex configuration
- **Automatic Route Generation** - File system-based routing organization
- **Functional Programming** - Intuitive interface development approach
- **Rich Built-in Features**
  - WebSocket support
  - XML parsing capability
  - CORS configuration
  - Function caching
  - Configurable logging levels
  - Express.js extension capabilities

## 🚀 Quick Start

> Your first hello world API

### Environment Requirements

- Node.js >= 22.0.0
- pnpm (recommended package manager)

### Installation

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

`tsconfig.json`:

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

For the examples below, create the above three files (package.json, tsconfig.json, and nodemon.json) in your project root directory 'demo', then run `pnpm install simple-web` to install dependencies. If pnpm is not installed, first install it using `npm install -g pnpm`.

Example project structure:

```plain
demo
├── index.ts
├── package.json
├── tsconfig.json
├── nodemon.json
```

### Usage

Below is an example of the entry file `index.ts` that imports SimpleWeb and starts the service.

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

To start the project, run `pnpm dev` in the project root directory.

The default service port is `2342`, and a `functions` directory is automatically generated in the root directory. All **API functions** must be written in this directory, as only functions in this directory will be registered as routes.

The simple web framework uses a file system-based routing organization. For example, `functions/hello.ts` corresponds to the route `/hello`, and `functions/user/info.ts` corresponds to the route `/user/info`.

When accessing each API, the `default` function is executed by default, so you need to define a default export function using `export default async function` or `export default function`.

Let's create your first hello API:

`functions/hello.ts`

```typescript
import type { FunctionContext } from 'simple-web23'

export default async function (ctx: FunctionContext) {
    return {
        data: 'hello'
    }
}
```

Most web development requires **databases** and **object storage**. Below are examples of using MongoDB and S3 object storage.

The simple web framework supports writing persistent clients outside the API function directory, such as database clients, S3 object storage clients, and cron jobs. It's recommended to write these clients and cron jobs outside the API function directory.

### Using MongoDB

Run `pnpm install mongodb` in the project root directory to install the MongoDB client. Create a `mongo.ts` file in the `client` directory with the MongoDB client code.

```typescript
import { MongoClient } from 'mongodb'

// In production, remember to replace username and password with environment variables
// const username = process.env.MONGO_USERNAME
// const password = process.env.MONGO_PASSWORD
// const uri = `mongodb://${username}:${password}@test-mongodb.ns-1k9qk3v6.svc:27017`
const uri = "mongodb://root:tf44dbrn@dbconn.sealosgzg.site:45222/?directConnection=true"

// Create MongoDB client instance
export const client = new MongoClient(uri)
```

Create a `mongo-test.ts` file in the `functions` directory with MongoDB test code.

```typescript
import { FunctionContext } from 'simple-web23'
import { client } from '../client/mongo'

export default async function (ctx: FunctionContext) {
    const database = client.db('test')
    const collection = database.collection('test')

    // Create test data
    console.log('--- Creating test data ---')
    const insertResult = await collection.insertMany([
        { name: 'John', age: 25, city: 'Beijing' },
        { name: 'Jane', age: 30, city: 'Shanghai' }
    ])
    console.log('Insert result:', insertResult)

    // Query all data
    console.log('\n--- Querying all data ---')
    const allDocs = await collection.find({}).toArray()
    console.log('All data:', allDocs)

    // Query single document
    console.log('\n--- Querying single document ---')
    const oneDoc = await collection.findOne({ name: 'John' })
    console.log('John\'s data:', oneDoc)

    // Update data
    console.log('\n--- Updating data ---')
    const updateResult = await collection.updateOne(
        { name: 'John' },
        { $set: { age: 26, city: 'Shenzhen' } }
    )
    console.log('Update result:', updateResult)

    // View updated data
    const updatedDoc = await collection.findOne({ name: 'John' })
    console.log('John\'s updated data:', updatedDoc)

    // Delete data
    console.log('\n--- Deleting data ---')
    const deleteResult = await collection.deleteOne({ name: 'Jane' })
    console.log('Delete result:', deleteResult)

    // Final query of all data
    console.log('\n--- Final data ---')
    const finalDocs = await collection.find({}).toArray()
    console.log('Final all data:', finalDocs)

    return { message: 'Test completed' }
}
```

### Using S3 Object Storage

Run `pnpm install @aws-sdk/client-s3` in the project root directory to install the S3 client. Create an `s3.ts` file in the `client` directory with the S3 client code.

```typescript
import { S3Client, ListObjectsV2Command, PutObjectCommand, _Object } from "@aws-sdk/client-s3"

// Create S3 client
// In production, remember to replace credentials with environment variables
// const accessKeyId = process.env.S3_ACCESS_KEY_ID
// const secretAccessKey = process.env.S3_SECRET_ACCESS_KEY

const s3Client = new S3Client({
    region: "cn-north-1", // e.g., "ap-northeast-1"
    endpoint: "https://objectstorageapi.gzg.sealos.run", // e.g., "https://s3.amazonaws.com" or custom endpoint
    credentials: {
        accessKeyId: "xxxxxxxxxx",
        secretAccessKey: "xxxxxxxxxx"
    },
    // For custom endpoints (like MinIO), you may need these settings
    forcePathStyle: true, // Force path style instead of virtual hosted style
})

// List files in bucket
async function listFiles(bucketName: string) {
    try {
        const command = new ListObjectsV2Command({
            Bucket: bucketName,
        })

        const response = await s3Client.send(command)

        // Print file list
        response.Contents?.forEach((file: _Object) => {
            console.log(`Filename: ${file.Key}, Size: ${file.Size} bytes`)
        })

        return response.Contents
    } catch (error) {
        console.error("Failed to list files:", error)
        throw error
    }
}

// Upload file to S3
async function uploadFile(bucketName: string, key: string, fileContent: Buffer) {
    try {
        const command = new PutObjectCommand({
            Bucket: bucketName,
            Key: key,
            Body: fileContent,
        })

        const response = await s3Client.send(command)
        console.log("File upload successful:", response)
        return response
    } catch (error) {
        console.error("File upload failed:", error)
        throw error
    }
}

export { listFiles, uploadFile }
```

Create an `s3-test.ts` file in the `functions` directory with S3 test code.

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

## 🎯 Future Plans

- [ ] Plugin system support
- [ ] Global context definition
- [ ] Lifecycle hooks
- [ ] Path routing enhancement
- [ ] OpenAPI integration
- [ ] Multi-language support (Python/Go/Java)

## 🤝 Contribution Guidelines

Issues and Pull Requests are welcome.
