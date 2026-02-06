# OpenClaw DevBox 运行时

基于 [Sealos DevBox](https://sealos.io/) 的运行时模板，用于运行 [OpenClaw](https://openclaw.ai/) —— 你的个人 AI 助手，支持 Discord、Telegram、Slack 与网页端。

## 什么是 OpenClaw？

OpenClaw 是一款开源的个人 AI 助手，让你在常用平台上与先进大模型对话。通过统一界面接入 Claude、GPT-4、Gemini 等多种模型。

**特点：**
- 一个助手，处处可用 —— Discord、Telegram、Slack、WhatsApp 或网页
- 多模型支持 —— Claude、GPT-5.2、Gemini、Llama、DeepSeek，以及通过 Ollama 的本地模型
- 自托管 —— 完全掌控数据与隐私
- 现代化网页界面，支持实时对话

## 部署指南

### 1. 登录 Sealos

访问 [cloud.sealos.run](https://cloud.sealos.run) 并完成注册登录。

### 2. 创建 DevBox 实例

1. 在 Sealos 桌面打开 **DevBox** 应用
2. 点击 **新建 DevBox**
3. 在模板搜索框中输入 `OpenClaw`
4. 选中 OpenClaw 模板并点击部署
5. 等待实例状态变为 `Running`

### 3. 连接开发环境

从 DevBox 界面右上角选择 IDE 进行远程连接：

- VS Code
- Cursor
- JetBrains IDE

IDE 将自动建立与云端 DevBox 的连接。

### 4. 配置环境变量

打开项目根目录的 `.env` 文件，配置以下环境变量：

```bash
# Gateway 认证令牌（必填）
CLAWDBOT_GATEWAY_TOKEN=<your-token>

# AI 模型配置（必填）
OPENAI_BASE_URL=<api-base-url>
OPENAI_API_KEY=<your-api-key>
OPENAI_MODEL=<model-id>
```

#### 生成 Gateway Token

在终端执行以下命令生成随机令牌：

```bash
openssl rand -hex 32
```

#### 配置 AI 模型（推荐使用 Sealos AI Proxy）

1. 返回 Sealos 桌面，展开更多应用

   ![](https://images.icloudnative.io/uPic/2026-01-30-15-17-voSubr.png)

2. 打开 **AI Proxy** 应用

   ![](https://images.icloudnative.io/uPic/2026-01-30-15-18-oZG6iD.png)

3. 创建 API Key 并复制 URL 和 Key

   ![](https://images.icloudnative.io/uPic/2026-01-30-15-20-ysOMbV.png)

4. 填入 `.env` 文件：

   ```bash
   OPENAI_BASE_URL=https://aiproxy.xxx.sealos.run/v1
   OPENAI_API_KEY=sk-xxxxxxxxxx
   OPENAI_MODEL=glm-4.7
   ```

可在模型广场选择其他可用模型：

![](https://images.icloudnative.io/uPic/2026-02-05-17-54-fyGJuG.png)

### 5. 重启 DevBox

返回 Sealos DevBox 界面，点击 **重启** 按钮：

![](https://images.icloudnative.io/uPic/2026-02-05-17-54-GOOc5S.jpg)

等待重启完成。

### 6. 访问服务

重启完成后，等待公网调试地址状态变为 **可访问**，点击公网地址进入 Web 界面。

### 7. 连接 Gateway

在 Overview 界面，将步骤 4 中生成的 `CLAWDBOT_GATEWAY_TOKEN` 填入 Gateway Token 输入框，点击 **Connect**：

![](https://images.icloudnative.io/uPic/2026-02-05-17-55-U6HywP.png)

Status 将从 `Disconnected` 变为 `Connected`。

### 8. 开始使用

切换到 Chat 界面，即可开始与 AI 助手对话：

![](https://images.icloudnative.io/uPic/2026-02-05-17-55-rD9Lp4.png)

## 环境变量说明

| 变量 | 必填 | 说明 |
|------|------|------|
| `CLAWDBOT_GATEWAY_TOKEN` | 是 | Gateway 认证令牌，使用 `openssl rand -hex 32` 生成 |
| `OPENAI_API_KEY` | 是 | OpenAI 兼容 API 密钥 |
| `OPENAI_BASE_URL` | 是 | API 基础地址（如 `https://api.openai.com`） |
| `OPENAI_MODEL` | 是 | 模型 ID（如 `claude-opus-4.5`、`glm-4.7`） |

## 常见问题

**网页显示「unauthorized」**
- 请使用带 `?token=...` 的认证链接访问

**网关无法启动**
- 确认 `.env` 中已设置 `CLAWDBOT_GATEWAY_TOKEN`

**LLM 连接错误**
- 确认 `.env` 中的 `OPENAI_API_KEY` 有效
- 检查 `OPENAI_BASE_URL` 和 `OPENAI_MODEL` 是否正确
- 确认账户有可用额度

## 相关链接

- [OpenClaw 文档](https://docs.openclaw.ai/)
- [OpenClaw GitHub](https://github.com/openclaw/openclaw)
- [社区 Discord](https://discord.com/invite/clawd)
- [Sealos DevBox](https://sealos.io/)

## 许可证

本运行时按原样提供。OpenClaw 为开源项目，遵循其自身许可证。
