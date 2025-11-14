# DevBox Runtime 镜像版本爬取脚本开发提示词

## 项目概述

请为 DevBox Runtime 项目开发一个镜像版本爬取脚本，用于获取 GitHub Container Registry (GHCR) 中所有 devbox 镜像的版本信息，特别关注以"v"开头的版本号。

## 技术需求

### 基本要求
- **编程语言**: Python 3.8+
- **目标仓库**: GitHub Container Registry (`ghcr.io/labring-actions/devbox/`)
- **输出格式**: 控制台显示 + JSON文件 + CSV文件
- **特殊关注**: 重点标记和处理以"v"开头的版本号

### 功能特性
1. **并发爬取**: 使用异步请求提高效率
2. **版本过滤**: 识别和特殊标记"v"开头的版本
3. **镜像分类**: 按照操作系统、语言、框架、服务进行分类
4. **进度显示**: 实时显示爬取进度
5. **错误处理**: 完善的异常处理和重试机制
6. **多格式输出**: 控制台彩色输出 + JSON + CSV

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

### 1. GHCR API 调用

**API 端点示例**:
- 获取仓库标签: `https://api.github.com/users/labring-actions/packages/container/package/devbox/versions`
- 或使用 Docker Registry API: `https://ghcr.io/v2/labring-actions/devbox/tags/list`

**认证要求**:
- GitHub Token (环境变量 `GITHUB_TOKEN`)
- 或者使用公开 API（有限制）

### 2. 镜像分类逻辑

根据镜像名称进行分类：
- **操作系统**: `debian-*`, `ubuntu-*`, `alpine-*`
- **语言**: `python-*`, `go-*`, `node-*`, `java-*`, `php-*`, `rust-*`, `cpp-*`, `dotnet-*`
- **框架**: `django-*`, `flask-*`, `react-*`, `vue-*`, `angular-*`, `express-*`, `spring-*`
- **服务**: `mcp-*`, `nginx-*`, `redis-*`, `mysql-*`

### 3. 版本解析规则

**版本号格式识别**:
- `v1.2.3` - 正式版本
- `v1.2.3-beta` - 预发布版本
- `v1.2.3-rc1` - 候选版本
- `latest` - 最新版本
- 数字版本: `1.2.3`, `2024.01.01`

**特殊处理**:
- "v"开头的版本需要在输出中特殊标记（如用颜色或符号）
- 按版本号进行排序（语义化版本排序）

### 4. 数据结构设计

```python
# 单个镜像信息结构
{
    "name": "python",
    "version": "3.12.0",
    "full_tag": "python-3.12.0",
    "category": "language",
    "is_versioned": True,  # 是否以v开头
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z",
    "size": 123456789,
    "digest": "sha256:..."
}
```

### 5. 依赖库要求

```txt
aiohttp>=3.8.0
asyncio-throttle>=1.0.2
colorama>=0.4.4
tqdm>=4.64.0
pandas>=1.5.0  # 可选，用于CSV处理
click>=8.0.0   # 可选，用于命令行界面
python-dateutil>=2.8.0
```

## 实现指导

### 1. 主脚本实现要点

```python
import asyncio
import aiohttp
from tqdm import tqdm
from utils.ghcr_client import GHCRClient
from utils.version_parser import VersionParser
from utils.output_formatter import OutputFormatter

async def main():
    # 初始化客户端
    async with aiohttp.ClientSession() as session:
        client = GHCRClient(session)
        parser = VersionParser()
        formatter = OutputFormatter()

        # 获取所有镜像标签
        tags = await client.get_all_tags()

        # 解析版本信息
        versions = parser.parse_tags(tags)

        # 输出结果
        await formatter.output_all(versions)
```

### 2. GHCR API 客户端实现

```python
class GHCRClient:
    def __init__(self, session, token=None):
        self.session = session
        self.token = token
        self.base_url = "https://ghcr.io/v2"

    async def get_all_tags(self, repository="labring-actions/devbox"):
        # 实现获取所有标签的逻辑
        # 支持分页和重试
        pass

    async def get_tag_details(self, repository, tag):
        # 获取特定标签的详细信息
        pass
```

### 3. 版本解析器实现

```python
class VersionParser:
    def __init__(self):
        self.category_patterns = {
            'os': [r'debian-', r'ubuntu-', r'alpine-'],
            'language': [r'python-', r'go-', r'node-', r'java-'],
            'framework': [r'django-', r'react-', r'vue-', r'angular-'],
            'service': [r'mcp-', r'nginx-', r'redis-']
        }

    def parse_tags(self, tags):
        # 解析标签并分类
        # 识别版本号格式
        # 返回结构化数据
        pass

    def is_versioned(self, version):
        # 检查是否为语义化版本
        # 特别关注v开头的版本
        return version.startswith('v') or re.match(r'\d+\.\d+\.\d+', version)
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
总镜像数: 156
语言运行时: 45 (其中 v 开头版本: 12)
框架运行时: 78 (其中 v 开头版本: 23)
操作系统: 12 (其中 v 开头版本: 3)
服务运行时: 21 (其中 v 开头版本: 5)

📋 镜像版本列表:
✅ v1.2.3    python-3.12.0      language    2024-01-01
✅ v2.0.0    react-18.2.0       framework   2024-01-02
⚡ latest    django-latest       framework   2024-01-03
📦 1.23.0    go-1.23.0          language    2024-01-04
```

### 2. JSON 输出格式
```json
{
  "metadata": {
    "total_count": 156,
    "categories": {
      "language": {"count": 45, "versioned": 12},
      "framework": {"count": 78, "versioned": 23},
      "os": {"count": 12, "versioned": 3},
      "service": {"count": 21, "versioned": 5}
    },
    "crawl_time": "2024-01-01T12:00:00Z"
  },
  "images": [
    {
      "name": "python",
      "version": "3.12.0",
      "full_tag": "python-3.12.0",
      "category": "language",
      "is_versioned": false,
      "created_at": "2024-01-01T00:00:00Z",
      "updated_at": "2024-01-01T00:00:00Z"
    }
  ]
}
```

### 3. CSV 输出格式
```csv
name,version,full_tag,category,is_versioned,created_at,updated_at
python,3.12.0,python-3.12.0,language,False,2024-01-01T00:00:00Z,2024-01-01T00:00:00Z
django,v4.2.16,django-4.2.16,framework,True,2024-01-02T00:00:00Z,2024-01-02T00:00:00Z
```

## 错误处理和重试机制

1. **网络错误**: 自动重试3次，间隔递增
2. **API限流**: 根据Retry-After头进行延迟
3. **认证失败**: 提供清晰的错误提示
4. **数据解析错误**: 记录错误并继续处理其他数据

## 性能要求

1. **并发数**: 默认10个并发请求，可配置
2. **超时时间**: 请求超时30秒
3. **内存使用**: 流式处理，避免大量数据堆积
4. **缓存机制**: 可选择启用本地缓存

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

### 环境变量
```bash
export GITHUB_TOKEN=your_token_here  # 可选，提高API限制
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
    --retry 5
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