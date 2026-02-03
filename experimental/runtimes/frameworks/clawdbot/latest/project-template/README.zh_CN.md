# OpenClaw DevBox Runtime

A [Sealos DevBox](https://sealos.io/) runtime template for running [OpenClaw](https://clawd.bot/) — your personal AI assistant across Discord, Telegram, Slack, and the web.

## What is OpenClaw?

OpenClaw is an open-source personal AI assistant that lets you interact with advanced LLMs through your favorite platforms. Connect Claude, GPT-4, Gemini, and more through a single interface.

**Highlights:**
- One assistant, everywhere — Discord, Telegram, Slack, WhatsApp, or web
- Multi-model support — Claude, GPT-5.2, Gemini, Llama, DeepSeek, and local models via Ollama
- Self-hosted — Full control over your data and privacy
- Modern web interface with real-time chat

## Quick Start on DevBox

1. **Create a DevBox runtime** from this template in the Sealos DevBox template store

2. **Copy `.env.example` to `.env`** and fill in your values:
   ```bash
   # Required — generate with: openssl rand -hex 32
   export CLAWDBOT_GATEWAY_TOKEN=your-generated-token

   # OpenAI configuration
   export OPENAI_BASE_URL=https://api.openai.com
   export OPENAI_MODEL=claude-opus-4.5
   export OPENAI_API_KEY=sk-...
   ```

3. **Restart the DevBox** — OpenClaw starts automatically on boot

4. **Access the web interface** at `http://localhost:18789`

## Configuration

Copy `.env.example` to `.env` and fill in the required values:

### Required Variables

| Variable | Description |
|----------|-------------|
| `CLAWDBOT_GATEWAY_TOKEN` | Generate with `openssl rand -hex 32` |
| `OPENAI_API_KEY` | Your OpenAI API key |
| `OPENAI_BASE_URL` | OpenAI API base URL (e.g., `https://api.openai.com`) |
| `OPENAI_MODEL` | Model to use (e.g., `claude-opus-4.5`, `claude-sonnet-4.5`) |

## Troubleshooting

**Web interface shows "unauthorized"**
- Make sure you're using the authenticated URL with `?token=...`

**Gateway won't start**
- Verify `CLAWDBOT_GATEWAY_TOKEN` is set in `.env`

**LLM connection errors**
- Verify `OPENAI_API_KEY` is valid in `.env`
- Check `OPENAI_BASE_URL` and `OPENAI_MODEL` are correct
- Ensure your OpenAI account has available credits

## Resources

- [OpenClaw Docs](https://docs.clawd.bot/)
- [OpenClaw GitHub](https://github.com/clawdbot/clawdbot)
- [Community Discord](https://discord.com/invite/clawd)
- [Sealos DevBox](https://sealos.io/)

## License

This runtime is provided as-is. OpenClaw is an open-source project with its own license.
