# OpenClaw DevBox 运行时

基于 [Sealos DevBox](https://sealos.io/) 的运行时模板，用于运行 [OpenClaw](https://clawd.bot/) —— 你的个人 AI 助手，支持 Discord、Telegram、Slack 与网页端。

## 什么是 OpenClaw？

OpenClaw 是一款开源的个人 AI 助手，让你在常用平台上与先进大模型对话。通过统一界面接入 Claude、GPT-4、Gemini 等多种模型。

**特点：**
- 一个助手，处处可用 —— Discord、Telegram、Slack、WhatsApp 或网页
- 多模型支持 —— Claude、GPT-5.2、Gemini、Llama、DeepSeek，以及通过 Ollama 的本地模型
- 自托管 —— 完全掌控数据与隐私
- 现代化网页界面，支持实时对话

## 在 DevBox 上快速开始

1. **创建 DevBox 运行时**：在 Sealos DevBox 模板商店中基于本模板创建

2. **将 `.env.example` 复制为 `.env`** 并填入你的配置：
   ```bash
   # 必填 — 生成方式：openssl rand -hex 32
   export CLAWDBOT_GATEWAY_TOKEN=your-generated-token

   # OpenAI 配置
   export OPENAI_BASE_URL=https://api.openai.com
   export OPENAI_MODEL=claude-opus-4.5
   export OPENAI_API_KEY=sk-...
   ```

3. **重启 DevBox** —— OpenClaw 会在启动时自动运行

4. **访问网页界面**：`http://localhost:18789`

## 配置说明

将 `.env.example` 复制为 `.env` 并填写所需变量：

### 必填变量

| 变量 | 说明 |
|------|------|
| `CLAWDBOT_GATEWAY_TOKEN` | 使用 `openssl rand -hex 32` 生成 |
| `OPENAI_API_KEY` | 你的 OpenAI API 密钥 |
| `OPENAI_BASE_URL` | OpenAI API 基础地址（如 `https://api.openai.com`） |
| `OPENAI_MODEL` | 使用的模型（如 `claude-opus-4.5`、`claude-sonnet-4.5`） |

## 常见问题

**网页显示「unauthorized」**
- 请使用带 `?token=...` 的认证链接访问

**网关无法启动**
- 确认 `.env` 中已设置 `CLAWDBOT_GATEWAY_TOKEN`

**LLM 连接错误**
- 确认 `.env` 中的 `OPENAI_API_KEY` 有效
- 检查 `OPENAI_BASE_URL` 和 `OPENAI_MODEL` 是否正确
- 确认 OpenAI 账户有可用额度

## 相关链接

- [OpenClaw 文档](https://docs.clawd.bot/)
- [OpenClaw GitHub](https://github.com/clawdbot/clawdbot)
- [社区 Discord](https://discord.com/invite/clawd)
- [Sealos DevBox](https://sealos.io/)

## 许可证

本运行时按原样提供。OpenClaw 为开源项目，遵循其自身许可证。
