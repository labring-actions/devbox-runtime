# 依赖关系管理

本文档介绍如何使用新的依赖关系管理功能来优化Docker镜像构建过程。

## 概述

新的依赖关系管理系统解决了之前CI中base image和language image依赖关系不明确的问题，实现了：

1. **动态依赖分析**：自动分析镜像间的依赖关系
2. **分层构建**：按照依赖顺序构建镜像
3. **依赖验证**：确保所有依赖都可用
4. **可视化**：生成依赖关系图

## 依赖层次结构

```
Level 0: Base Images (OS)
├── debian-ssh-12.6
├── ubuntu-24.04
└── ubuntu-cuda-24.04

Level 1: Language Images
├── node.js-20 (depends on debian-ssh-12.6)
├── python-3.12 (depends on debian-ssh-12.6)
├── go-1.22.5 (depends on debian-ssh-12.6)
└── java-openjdk17 (depends on debian-ssh-12.6)

Level 2: Framework Images
├── react-18.2.0 (depends on node.js-20)
├── django-4.2.16 (depends on python-3.12)
├── spring-boot-3.3.2 (depends on java-openjdk17)
└── gin-v1.10.0 (depends on go-1.22.5)
```

## 新增命令

### 1. 依赖分析

```bash
# 分析所有包的依赖关系
./runtimectl ci analyze-dependencies

# 输出JSON格式的依赖图
{
  "nodes": [...],
  "levels": [
    ["base images"],
    ["language images"],
    ["framework images"]
  ]
}
```

### 2. 构建顺序

```bash
# 获取基于依赖关系的构建顺序
./runtimectl ci build-order

# 输出按依赖顺序排列的Dockerfile路径数组
```

### 3. 依赖验证

```bash
# 验证所有依赖关系是否正确
./runtimectl ci validate-dependencies
```

### 4. 依赖图可视化

```bash
# 生成Mermaid格式的依赖关系图
./runtimectl ci dependency-graph
```

### 5. 增强的构建矩阵

```bash
# 生成包含依赖关系的构建矩阵
./runtimectl ci build-matrix --with-dependencies

# 只构建变更的镜像及其依赖
./runtimectl ci build-matrix --changed --commit1 <hash1> --commit2 <hash2> --with-dependencies
```

## CI工作流改进

### 分层构建流程

新的CI工作流实现了三层构建：

1. **Base Images** → 构建操作系统基础镜像
2. **Language Images** → 构建语言运行时镜像（依赖base images）
3. **Framework Images** → 构建框架应用镜像（依赖language images）

### 工作流文件

- `docker-build.yml` - 更新后的主工作流，支持依赖分析
- `docker-build-with-dependencies.yml` - 完整的分层构建工作流

### 关键改进

1. **动态依赖分析**：不再硬编码base images，而是动态分析
2. **智能构建顺序**：根据依赖关系确定构建顺序
3. **依赖验证**：构建前验证所有依赖都可用
4. **可视化支持**：生成依赖关系图

## 使用示例

### 本地开发

```bash
# 1. 分析当前项目的依赖关系
./runtimectl ci analyze-dependencies

# 2. 验证依赖关系
./runtimectl ci validate-dependencies

# 3. 查看构建顺序
./runtimectl ci build-order

# 4. 生成依赖图
./runtimectl ci dependency-graph
```

### CI/CD集成

```yaml
# 在GitHub Actions中使用
- name: Analyze dependencies
  run: |
    ./runtimectl ci analyze-dependencies

- name: Validate dependencies
  run: |
    ./runtimectl ci validate-dependencies

- name: Get build order
  run: |
    build_order=$(./runtimectl ci build-order)
    echo "build_order=$build_order" >> $GITHUB_OUTPUT
```

## 优势

1. **构建可靠性**：确保依赖镜像先构建完成
2. **构建效率**：利用Docker layer缓存优化
3. **维护性**：清晰的依赖关系，便于调试
4. **扩展性**：支持复杂的依赖关系
5. **可视化**：直观的依赖关系图

## 迁移指南

### 从旧工作流迁移

1. **更新CI调用**：
   ```bash
   # 旧方式
   ./runtimectl ci build-matrix

   # 新方式（推荐）
   ./runtimectl ci build-matrix --with-dependencies
   ```

2. **添加依赖验证**：
   ```yaml
   - name: Validate dependencies
     run: ./runtimectl ci validate-dependencies
   ```

3. **使用分层构建**：
   - 使用 `docker-build-with-dependencies.yml` 工作流
   - 或更新现有工作流使用新的依赖分析功能

### 向后兼容

- 所有现有命令保持兼容
- 新的 `--with-dependencies` 参数是可选的
- 旧的工作流仍然可以正常工作

## 故障排除

### 常见问题

1. **依赖验证失败**：
   ```bash
   # 检查依赖关系
   ./runtimectl ci analyze-dependencies

   # 验证特定包的依赖
   ./runtimectl ci validate-dependencies
   ```

2. **构建顺序问题**：
   ```bash
   # 查看构建顺序
   ./runtimectl ci build-order

   # 检查依赖图
   ./runtimectl ci dependency-graph
   ```

3. **镜像引用更新失败**：
   - 确保依赖镜像已构建完成
   - 检查镜像名称格式是否正确

## 最佳实践

1. **定期验证依赖**：在CI中添加依赖验证步骤
2. **使用依赖图**：可视化复杂的依赖关系
3. **分层构建**：利用分层构建优化构建时间
4. **依赖文档**：维护清晰的依赖关系文档
5. **测试依赖变更**：修改依赖时充分测试
