# 三层构建方案

本文档介绍如何使用简化的三层构建方案来解决GitHub Actions矩阵并行构建不按`build_order`执行的问题。

## 方案概述

### 三层结构

1. **Level 0 (OS层)**: 操作系统基础镜像
   - 无依赖，可以并行构建
   - 例如：debian-ssh, ubuntu, ubuntu-cuda

2. **Level 1 (Language层)**: 语言运行时镜像
   - 依赖OS层镜像
   - 例如：node.js, python, go, java

3. **Level 2 (Framework层)**: 框架应用镜像
   - 依赖Language层镜像
   - 例如：react, django, spring-boot, gin

### 构建流程

```
Level 0 (OS) → Level 1 (Language) → Level 2 (Framework)
     ↓              ↓                    ↓
   并行构建        并行构建             并行构建
```

## 核心组件

### 1. 可重用的构建Action

**文件**: `.github/actions/build-level/action.yml`

**功能**:
- 处理单个依赖层的所有构建逻辑
- 支持依赖镜像引用更新
- 支持多镜像仓库推送
- 可配置的构建参数

**输入参数**:
- `level_index`: 依赖层索引 (0, 1, 2)
- `level_packages`: 该层的包列表 (JSON数组)
- `tag`: 镜像标签
- `tag_cn`: CN镜像标签
- `aliyun_enabled`: 是否启用阿里云镜像仓库

### 2. 三层构建工作流

**文件**: `.github/workflows/docker-build-three-levels.yml`

**特点**:
- 使用可重用的`build-level` action
- 三层串行，层内并行
- 清晰的依赖关系
- 简化的配置

## 使用方法

### 1. 本地测试

```bash
# 查看依赖层次
./bin/runtimectl ci analyze-dependencies

# 查看构建顺序
./bin/runtimectl ci build-order

# 验证依赖关系
./bin/runtimectl ci validate-dependencies
```

### 2. 触发构建

```bash
# 手动触发工作流
gh workflow run docker-build-three-levels.yml \
  --field tag=latest \
  --field build_all=true \
  --field aliyun_enabled=false
```

### 3. 监控构建

工作流会显示：
- 每个层次的包数量
- 构建进度
- 依赖关系图

## 技术实现

### 依赖层次计算

```go
// 在 runtime.go 中
switch pkg.Kind {
case "os":
    node.Level = 0 // Base level
case "language":
    node.Level = 1 // Language level
case "framework", "service":
    node.Level = 2 // Framework level
}
```

### 工作流依赖关系

```yaml
# Level 0: 无依赖
build-level-0:
  needs: define-matrix

# Level 1: 依赖 Level 0
build-level-1:
  needs: [define-matrix, build-level-0]

# Level 2: 依赖 Level 1
build-level-2:
  needs: [define-matrix, build-level-1]
```

### 条件构建

```yaml
# 只有当层中有包时才构建
if: ${{ fromJson(needs.define-matrix.outputs.level_0) != null && length(fromJson(needs.define-matrix.outputs.level_0)) > 0 }}
```

## 优势

### 1. 简化维护
- 通用构建逻辑抽取到可重用action
- 减少代码重复
- 易于修改和扩展

### 2. 清晰结构
- 三层固定结构，易于理解
- 明确的依赖关系
- 可预测的构建顺序

### 3. 高效构建
- 层内并行，层间串行
- 平衡构建速度和依赖关系
- 充分利用并行资源

### 4. 灵活配置
- 支持条件构建
- 支持多镜像仓库
- 支持增量构建

## 与原始方案对比

| 特性 | 原始矩阵构建 | 三层构建方案 |
|------|-------------|-------------|
| 构建顺序 | 无保证 | 严格按依赖顺序 |
| 代码复用 | 低 | 高 |
| 维护复杂度 | 高 | 低 |
| 构建效率 | 高 | 中等 |
| 依赖保证 | 无 | 100% |

## 迁移指南

### 从原始工作流迁移

1. **替换工作流文件**:
   ```bash
   # 备份原始工作流
   mv .github/workflows/docker-build.yml .github/workflows/docker-build.yml.backup

   # 使用新的三层构建工作流
   cp .github/workflows/docker-build-three-levels.yml .github/workflows/docker-build.yml
   ```

2. **验证构建**:
   ```bash
   # 测试依赖分析
   ./bin/runtimectl ci analyze-dependencies

   # 测试构建顺序
   ./bin/runtimectl ci build-order
   ```

3. **监控构建**:
   - 检查每个层次的包数量
   - 验证依赖关系
   - 确认构建顺序

## 扩展性

### 添加新的依赖层

如果需要支持更复杂的依赖关系，可以：

1. **修改层次计算逻辑**:
   ```go
   // 在 runtime.go 中添加新的层次
   case "middleware":
       node.Level = 1.5 // 中间层
   ```

2. **添加新的构建作业**:
   ```yaml
   build-level-1.5:
     needs: [define-matrix, build-level-0]
     # ... 构建逻辑
   ```

3. **更新依赖关系**:
   ```yaml
   build-level-2:
     needs: [define-matrix, build-level-1.5]  # 更新依赖
   ```

## 总结

三层构建方案通过以下方式解决了原始问题：

1. **依赖顺序保证**: 严格按三层顺序构建
2. **代码复用**: 通用构建逻辑抽取到可重用action
3. **简化维护**: 清晰的三层结构，易于理解和修改
4. **高效构建**: 层内并行，层间串行，平衡效率和依赖关系

这个方案既解决了依赖顺序问题，又保持了代码的简洁性和可维护性。
