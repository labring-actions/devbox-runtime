# 开发指南

## 项目结构

项目采用模块化的目录结构，主要组件包括：

- **runtimes/** - 运行时包定义
- **tools/** - 构建和部署工具
- **config/** - 配置文件管理
- **api/** - Go API 代码
- **cmd/** - 命令行工具入口

## 添加新的运行时

1. 在 `runtimes/` 下创建相应的目录结构
2. 添加 Dockerfile 和项目文件
3. 更新配置文件中的映射信息
4. 运行 `./runtimectl scan` 更新元数据

## 构建流程

1. 修改代码或配置
2. 运行 `./runtimectl ci generate-config` 生成配置
3. 运行 `./runtimectl ci build-and-push <dockerfile> <image1> <image2> [--cn]` 构建镜像
4. 提交更改

## 测试

```bash
# 验证配置
./runtimectl validate

# 扫描运行时
./runtimectl scan
```
