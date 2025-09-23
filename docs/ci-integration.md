# CI/CD 集成指南

本文档介绍如何使用 `runtimectl` 工具来优化 GitHub Actions CI/CD 流程。

## 新增的 CI 命令

### 1. `ci build-matrix` - 生成构建矩阵

生成用于 GitHub Actions 矩阵构建的 Dockerfile 列表。

```bash
# 获取所有 Dockerfile
./runtimectl ci build-matrix

# 获取变更的 Dockerfile（需要 git 历史）
./runtimectl ci build-matrix --changed --commit1 <hash1> --commit2 <hash2>
```

**输出格式**：JSON 数组，可直接用于 GitHub Actions matrix。

### 2. `ci image-name` - 生成镜像名称

根据 Dockerfile 路径和参数生成完整的镜像名称。

```bash
./runtimectl ci image-name <dockerfile> <registry> <namespace> <tag>
```

**示例**：
```bash
./runtimectl ci image-name "runtimes/frameworks/vue/v3.4.29/Dockerfile" "ghcr.io" "labring-actions" "latest"
# 输出: ghcr.io/labring-actions/devbox/vue-v3.4.29:latest
```

### 3. `ci build` - 构建镜像

构建 Docker 镜像，支持 CN 修改和推送选项。

```bash
./runtimectl ci build <dockerfile> <image-name> [--cn] [--push]
```

**选项**：
- `--cn`: 应用中国镜像源修改
- `--push`: 构建后推送到仓库

### 4. `ci validate-build` - 验证构建配置

验证 Dockerfile 和构建配置的正确性。

```bash
./runtimectl ci validate-build <dockerfile>
```

**验证内容**：
- Dockerfile 是否存在
- 路径结构是否正确
- 项目目录是否存在

### 5. `ci generate-config` - 生成运行时配置

生成或更新运行时配置文件。

```bash
./runtimectl ci generate-config [--cn] [--tag <tag>]
```

**选项**：
- `--cn`: 生成中文版配置
- `--tag`: 指定标签版本

## GitHub Actions 集成

### 优化后的工作流

新的工作流使用 `runtimectl` 替代了多个 shell 脚本，提供更统一和可靠的构建流程。

#### 主要改进：

1. **统一的构建矩阵生成**
   ```yaml
   - name: Get build matrix
     run: |
       build_targets=$(./runtimectl ci build-matrix)
   ```

2. **自动镜像名称生成**
   ```yaml
   - name: Generate image names
     run: |
       ghcr_image_name=$(./runtimectl ci image-name "${{ matrix.build_target }}" "ghcr.io" "${{ github.repository_owner }}" "${{ tag }}")
   ```

3. **构建前验证**
   ```yaml
   - name: Validate build
     run: |
       ./runtimectl ci validate-build "${{ matrix.build_target }}"
   ```

4. **统一的构建命令**
   ```yaml
   - name: Build and push images
     run: |
       ./runtimectl ci build "${{ matrix.build_target }}" "${{ image_name }}" --push
   ```

### 工作流文件

- `docker-image.yml` - 主要的 Docker 镜像构建工作流
- `runtimectl-demo.yml` - 演示工作流，展示所有 CI 命令的使用

## 使用示例

### 本地开发

```bash
# 构建 runtimectl
go build -o runtimectl cmd/main.go cmd/commands.go

# 查看所有可用的运行时
./runtimectl list

# 生成构建矩阵
./runtimectl ci build-matrix

# 验证特定构建
./runtimectl ci validate-build "runtimes/frameworks/vue/v3.4.29/Dockerfile"

# 生成镜像名称
./runtimectl ci image-name "runtimes/frameworks/vue/v3.4.29/Dockerfile" "ghcr.io" "myorg" "v1.0.0"

# 构建镜像（不推送）
./runtimectl ci build "runtimes/frameworks/vue/v3.4.29/Dockerfile" "ghcr.io/myorg/devbox/vue-v3.4.29:v1.0.0"

# 构建并推送镜像
./runtimectl ci build "runtimes/frameworks/vue/v3.4.29/Dockerfile" "ghcr.io/myorg/devbox/vue-v3.4.29:v1.0.0" --push

# 生成运行时配置
./runtimectl ci generate-config --tag "v1.0.0"
```

### CI/CD 流程

1. **触发构建**：推送到 main 分支或手动触发
2. **生成矩阵**：使用 `runtimectl ci build-matrix` 获取需要构建的 Dockerfile
3. **验证构建**：对每个 Dockerfile 进行验证
4. **生成镜像名**：为每个构建目标生成镜像名称
5. **构建镜像**：并行构建所有镜像
6. **生成配置**：更新运行时配置文件

## 优势

### 1. **统一接口**
- 所有构建相关操作通过 `runtimectl` 统一管理
- 减少了对多个 shell 脚本的依赖

### 2. **更好的错误处理**
- Go 代码提供更好的错误处理和日志输出
- 统一的错误格式和退出码

### 3. **类型安全**
- 编译时检查，减少运行时错误
- 更好的参数验证

### 4. **可维护性**
- 代码集中在一个地方，易于维护和扩展
- 清晰的命令结构和文档

### 5. **可测试性**
- 每个命令都可以独立测试
- 支持单元测试和集成测试

## 迁移指南

### 从旧脚本迁移

1. **替换脚本调用**：
   ```bash
   # 旧方式
   bash script/get_all_dockerfile.sh

   # 新方式
   ./runtimectl ci build-matrix
   ```

2. **更新镜像名称生成**：
   ```bash
   # 旧方式
   bash script/get_image_name.sh "ghcr.io" "namespace" "dockerfile" "tag"

   # 新方式
   ./runtimectl ci image-name "dockerfile" "ghcr.io" "namespace" "tag"
   ```

3. **简化构建流程**：
   ```bash
   # 旧方式
   bash script/build_and_push_images.sh "dockerfile" "image1" "image2" "is_cn"

   # 新方式
   ./runtimectl ci build "dockerfile" "image1" --push
   ./runtimectl ci build "dockerfile" "image2" --cn --push
   ```

## 故障排除

### 常见问题

1. **构建失败**：使用 `ci validate-build` 检查 Dockerfile 配置
2. **镜像名称错误**：检查 Dockerfile 路径格式是否正确
3. **权限问题**：确保 runtimectl 有执行权限

### 调试技巧

```bash
# 启用详细输出
./runtimectl ci build-matrix -v

# 检查特定包的详细信息
./runtimectl info <package> <version>

# 验证构建配置
./runtimectl ci validate-build <dockerfile>
```
