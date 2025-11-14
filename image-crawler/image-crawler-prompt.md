# DevBox Runtime 镜像版本爬取脚本开发提示词

## 项目概述

请为 DevBox Runtime 项目开发一个镜像版本爬取脚本，用于获取 GitHub Container Registry (GHCR) 中所有 devbox 镜像的版本信息，并 **只保留以 "v" 开头的版本标签**。

## 技术需求

### 基本要求
- **编程语言**: Python 3.8+
- **镜像来源**: GitHub Container Registry (`ghcr.io/labring-actions/devbox/`)
- **镜像列表**: 自动扫描仓库内 `runtimes/` 目录下的 Dockerfile，推导镜像名称（`<分类>-<版本>`）
- **拉取方式**: 使用 [crane](https://github.com/google/go-containerregistry/tree/main/cmd/crane) CLI (`crane ls <repo>`)
- **输出格式**: 控制台 + JSON 文件 + CSV 文件
- **必选过滤**: 只保留并展示以 "v" 开头的标签（例如 `v0.2.2`、`v1.0.0-rc1`）

### 功能特性
1. **并发爬取**: 异步调度 `crane` 命令，提高拉取速度
2. **版本过滤**: 严格过滤出以 "v" 开头的标签，其余全部忽略
3. **镜像分类**: 通过 `runtimes/` 目录结构推导类别（操作系统、语言、框架、服务）
4. **进度显示**: 实时展示标签抓取进度
5. **错误处理**: `crane` 调用失败时自动重试并记录日志
6. **多格式输出**: 控制台彩色输出 + JSON + CSV（包含完整镜像路径）
7. **最新版本模式**: 通过 CLI 开关仅输出每个镜像最新版本（同时保留 `vX` 与 `vX-cn` 两个标签）

## 项目结构

```
image-crawler/
├── crawl_image_versions.py    # 主爬取脚本
├── requirements.txt           # Python 依赖文件
├── config/
│   └── config.py             # 配置文件
├── utils/
│   ├── __init__.py
│   ├── ghcr_client.py        # GHCR API 客户端
│   ├── version_parser.py     # 版本解析工具
│   └── output_formatter.py   # 输出格式化工具
├── output/                   # 输出目录
│   ├── versions.json         # JSON 格式输出
│   └── versions.csv          # CSV 格式输出
└── README.md                 # 使用说明文档
```

## 技术实现细节

### 1. GHCR 标签获取方式

- 使用 `crane ls ghcr.io/labring-actions/devbox/<镜像名>` 拉取全部标签
- 通过 `asyncio.create_subprocess_exec` 并发调用 `crane`，并对命令失败进行重试
- 不依赖 GitHub Token，完全基于公开仓库即可

### 2. 镜像分类逻辑

- 遍历仓库内 `runtimes/` 目录，读取 Dockerfile 的路径（`runtimes/<category>/<component>/<variant>/Dockerfile`）
- 使用目录名确定 `category`（languages/frameworks/services/operating-systems）
- `<component>-<variant>` 组成镜像名称，如 `python-3.12`
- 仍可配置正则匹配以扩展分类映射（如 `mcp-*` 属于 service）

### 3. 版本解析规则

**版本号格式识别**:
- `v1.2.3` - 正式版本
- `v1.2.3-beta` - 预发布版本
- `v1.2.3-rc1` - 候选版本
- `latest` - 最新版本
- 数字版本: `1.2.3`, `2024.01.01`

**特殊处理**:
- 仅保留以 "v" 开头的标签，其余标签直接丢弃
- 在控制台使用颜色或符号突出显示版本信息
- 输出按 **类别 + 镜像名称 + 版本号** 排序，方便对齐比对

### 4. 数据结构设计

```python
# 单个镜像信息结构
{
    "category": "language",
    "name": "python-3.12",
    "component": "python",
    "runtime_version": "3.12",
    "version": "v0.2.2",
    "registry": "ghcr.io",
    "repository": "labring-actions/devbox",
    "image_path": "ghcr.io/labring-actions/devbox/python-3.12",
    "full_tag": "ghcr.io/labring-actions/devbox/python-3.12:v0.2.2",
    "is_versioned": True,
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z",
    "size": 123456789,
    "digest": "sha256:...",
    "source": "crane"
}
```

### 5. 依赖库要求

```txt
tqdm>=4.64.0
colorama>=0.4.4
click>=8.0.0
pandas>=1.5.0  # 可选，用于CSV处理
python-dateutil>=2.8.0
packaging>=23.0

# 外部依赖
crane CLI (参考 go-containerregistry 项目)
```

## 实现指导

### 1. 主脚本实现要点

```python
import asyncio
from pathlib import Path
from tqdm import tqdm

from utils.runtime_inventory import discover_runtime_images
from utils.ghcr_client import GHCRClient
from utils.version_parser import VersionParser
from utils.output_formatter import OutputFormatter


async def main():
    runtime_images = discover_runtime_images(Path("runtimes"))
    client = GHCRClient()
    parser = VersionParser()
    formatter = OutputFormatter()

    with tqdm(desc="爬取镜像标签", unit="tag") as bar:
        tags = await client.get_all_tags(runtime_images, progress_cb=bar.update)
        bar.total = len(tags)
        bar.refresh()

    versions = parser.parse_tags(tags)
    await formatter.output_all(versions)
```

### 2. `crane` 调用客户端实现

```python
import asyncio

class GHCRClient:
    def __init__(self, crane_bin="crane", repository="labring-actions/devbox", concurrent=10):
        self.crane_bin = crane_bin
        self.repository = repository
        self.registry = "ghcr.io"
        self._semaphore = asyncio.Semaphore(concurrent)

    async def get_all_tags(self, runtimes, progress_cb=None):
        tasks = [asyncio.create_task(self._fetch_runtime(runtime, progress_cb)) for runtime in runtimes]
        tags = []
        for task in asyncio.as_completed(tasks):
            tags.extend(await task)
        return tags

    async def _fetch_runtime(self, runtime, progress_cb=None):
        repo = f"{self.registry}/{self.repository}/{runtime.image_name}"
        output = await self._run_crane(["ls", repo])
        return [
            {
                "image": runtime.image_name,
                "category": runtime.category,
                "component": runtime.component,
                "runtime_version": runtime.variant,
                "tag": tag,
                "registry": self.registry,
                "repository": self.repository,
            }
            for tag in output.splitlines()
            if tag
        ]

    async def _run_crane(self, args):
        cmd = [self.crane_bin, *args]
        async with self._semaphore:
            proc = await asyncio.create_subprocess_exec(*cmd, stdout=asyncio.subprocess.PIPE, stderr=asyncio.subprocess.PIPE)
            stdout, stderr = await proc.communicate()
        if proc.returncode != 0:
            raise RuntimeError(stderr.decode() or stdout.decode())
        return stdout.decode()
```

### 3. 版本解析器实现

```python
class VersionParser:
    def __init__(self, config):
        self.config = config

    def parse_tags(self, tags):
        results = []
        for tag in tags:
            if not tag["tag"].lower().startswith("v"):
                continue  # 严格保留 v* 标签
            category = self._categorize(tag["image"])
            results.append({
                **tag,
                "category": category,
                "full_tag": f"{tag['registry']}/{tag['repository']}/{tag['image']}:{tag['tag']}",
            })
        # 排序：类别 -> 名称 -> 版本
        results.sort(key=lambda item: (item["category"], item["image"], item["tag"]))
        return results
```

### 4. 输出格式化器实现

```python
class OutputFormatter:
    def __init__(self):
        self.color_map = {
            'versioned': 'green',  # v开头的版本
            'latest': 'yellow',
            'numeric': 'blue',
            'other': 'white'
        }

    async def output_console(self, versions):
        # 控制台彩色输出
        # 特殊标记v开头的版本
        pass

    async def output_json(self, versions, filename='output/versions.json'):
        # JSON格式输出
        pass

    async def output_csv(self, versions, filename='output/versions.csv'):
        # CSV格式输出
        pass
```

## 输出要求

### 1. 控制台输出格式
```
🔍 DevBox Runtime 镜像版本爬取结果
=====================================

📊 统计信息:
总镜像数: 86
- framework: 50 (其中 v 开头版本: 50)
- language: 30 (其中 v 开头版本: 30)
- os: 6 (其中 v 开头版本: 6)
- service: 0 (其中 v 开头版本: 0)

📋 镜像版本列表 (按类别+名称排序，展示类别 | 名称 | 版本 | 镜像全路径):
✅ framework  angular-v18      v0.2.2   ghcr.io/labring-actions/devbox/angular-v18:v0.2.2
✅ framework  angular-v18      v0.2.2-cn ghcr.io/labring-actions/devbox/angular-v18:v0.2.2-cn
✅ language   python-3.12      v0.2.2   ghcr.io/labring-actions/devbox/python-3.12:v0.2.2
✅ os         debian-12.6      v0.2.2   ghcr.io/labring-actions/devbox/debian-12.6:v0.2.2
```

### 2. JSON 输出格式
```json
{
  "metadata": {
    "total_count": 86,
    "categories": {
      "language": {"count": 30, "versioned": 30},
      "framework": {"count": 50, "versioned": 50},
      "os": {"count": 6, "versioned": 6}
    },
    "crawl_time": "2024-01-01T12:00:00Z"
  },
  "images": [
    {
      "category": "language",
      "name": "python",
      "component": "python",
      "runtime_version": "3.12",
      "registry": "ghcr.io",
      "repository": "labring-actions/devbox",
      "image_path": "ghcr.io/labring-actions/devbox/python-3.12",
      "version": "v0.2.2",
      "full_tag": "ghcr.io/labring-actions/devbox/python-3.12:v0.2.2",
      "is_versioned": true,
      "created_at": "2024-01-01T00:00:00Z",
      "updated_at": "2024-01-01T00:00:00Z",
      "digest": "sha256:...",
      "source": "crane"
    }
  ]
}
```

### 3. CSV 输出格式
```csv
category,name,component,runtime_version,version,full_tag,image_path,registry,repository,is_versioned,created_at,updated_at
language,python-3.12,python,3.12,v0.2.2,ghcr.io/labring-actions/devbox/python-3.12:v0.2.2,ghcr.io/labring-actions/devbox/python-3.12,ghcr.io,labring-actions/devbox,True,2024-01-01T00:00:00Z,2024-01-01T00:00:00Z
framework,angular-v18,angular,v18,v0.2.2,ghcr.io/labring-actions/devbox/angular-v18:v0.2.2,ghcr.io/labring-actions/devbox/angular-v18,ghcr.io,labring-actions/devbox,True,2024-01-02T00:00:00Z,2024-01-02T00:00:00Z
```

## 错误处理和重试机制

1. **命令失败**: `crane` 返回非 0 状态时自动重试3次（指数退避）
2. **命令缺失**: 当 `crane` 不在 PATH 中时，提示安装方法并退出
3. **输出异常**: 无法解析 `crane ls` 输出时记录日志并跳过该镜像
4. **数据解析错误**: 记录错误并继续处理其他数据

## 性能要求

1. **并发数**: 默认10个并发 `crane` 调用，可通过 CLI 配置
2. **超时时间**: 为每个子进程设置命令级超时（如 30 秒），超时后自动重试
3. **内存使用**: 标签结果使用流式合并，避免一次性加载过多数据
4. **缓存机制**: 可选择缓存 `crane ls` 结果以减少重复调用

## 测试要求

1. **单元测试**: 覆盖核心功能模块
2. **集成测试**: 测试完整的爬取流程
3. **性能测试**: 验证并发处理能力
4. **输出验证**: 确保各种格式输出正确

## 部署和使用

### 安装依赖
```bash
pip install -r requirements.txt
```

### 外部工具
```bash
# 安装 crane（macOS Homebrew 示例）
brew install go-containerregistry
```

### 运行脚本
```bash
# 基本用法
python crawl_image_versions.py

# 高级用法
python crawl_image_versions.py \
    --output-format json,csv \
    --filter "v*" \
    --concurrent 20 \
    --retry 5 \
    --latest-only
```

## 扩展功能（可选）

1. **配置文件支持**: 支持YAML/JSON配置文件
2. **定时任务**: 支持定时执行和增量更新
3. **通知功能**: 版本更新时发送通知
4. **Web界面**: 提供简单的Web查看界面
5. **数据库存储**: 支持将数据存储到数据库

## 注意事项

1. **API限制**: 注意GitHub API的调用限制
2. **数据准确性**: 验证获取数据的准确性
3. **错误日志**: 记录详细的错误日志
4. **代码质量**: 遵循Python PEP8编码规范
5. **文档完善**: 提供完整的API文档和使用说明

---

请根据以上详细的技术规格和实现指导，开发一个完整的镜像版本爬取脚本。确保代码质量高、功能完整、易于使用和维护。
- `--latest-only`: 仅输出每个镜像的最新版本（若存在 `-cn` 标签则与常规标签一起保留）
