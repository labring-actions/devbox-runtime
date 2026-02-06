# OpenClaw DevBox Runtime

A [Sealos DevBox](https://sealos.io/) runtime template for running [OpenClaw](https://openclaw.ai/) — your personal AI assistant across Discord, Telegram, Slack, and the web.

## What is OpenClaw?

OpenClaw is an open-source personal AI assistant that lets you interact with advanced LLMs through your favorite platforms. Connect Claude, GPT-4, Gemini, and more through a single interface.

**Highlights:**
- One assistant, everywhere — Discord, Telegram, Slack, WhatsApp, or web
- Multi-model support — Claude, GPT-5.2, Gemini, Llama, DeepSeek, and local models via Ollama
- Self-hosted — Full control over your data and privacy
- Modern web interface with real-time chat

## Deployment Guide

### 1. Log in to Sealos

Visit [sealos.io](https://sealos.io) and complete registration.

### 2. Deploy via AI Chat

In the Sealos homepage dialog, simply type:

```
Give me openclaw
```

The AI will automatically deploy the OpenClaw runtime for you.

After deployment, you will be redirected to the Canvas. For later changes, describe your requirements in the dialog to let AI apply updates, or click the relevant resource cards to modify settings.

### 3. Connect Your IDE

From the DevBox interface, select your preferred IDE for remote connection:

- VS Code
- Cursor
- JetBrains IDE

The IDE will automatically establish a connection to your cloud DevBox.

### 4. Configure Environment Variables

Open the `.env` file in the project root directory and configure the following environment variables:

```bash
# Gateway authentication token (required)
CLAWDBOT_GATEWAY_TOKEN=<your-token>

# AI model configuration (required)
OPENAI_BASE_URL=<api-base-url>
OPENAI_API_KEY=<your-api-key>
OPENAI_MODEL=<model-id>
```

#### Generate Gateway Token

Run the following command in the terminal to generate a random token:

```bash
openssl rand -hex 32
```

#### Configure AI Model (Recommended: Sealos AI Proxy)

1. Return to the Sealos desktop
2. Open the **AI Proxy** application
3. Create an API Key and copy the URL and Key
4. Fill in the `.env` file:

   ```bash
   OPENAI_BASE_URL=https://aiproxy.usw-1.sealos.io/v1
   OPENAI_API_KEY=sk-xxxxxxxxxx
   OPENAI_MODEL=claude-opus-4-5-20251101
   ```

You can select other available models from the model marketplace.

### 5. Restart DevBox

Return to the Canvas and click the **Restart** button on the DevBox card, then wait for the restart to complete.

### 6. Access the Service

After restart, wait for the public URL status to become **Accessible**, then click the public URL to enter the Web interface.

### 7. Connect Gateway

In the Overview interface, enter the `CLAWDBOT_GATEWAY_TOKEN` generated in Step 4 into the Gateway Token input field, then click **Connect**.

The Status will change from `Disconnected` to `Connected`.

### 8. Start Using

Switch to the Chat interface to start conversing with your AI assistant.

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `CLAWDBOT_GATEWAY_TOKEN` | Yes | Gateway authentication token, generate with `openssl rand -hex 32` |
| `OPENAI_API_KEY` | Yes | OpenAI-compatible API key |
| `OPENAI_BASE_URL` | Yes | API base URL (e.g., `https://api.openai.com`) |
| `OPENAI_MODEL` | Yes | Model ID (e.g., `claude-opus-4-5-20251101`, `gpt-4o`) |

## Troubleshooting

**Web interface shows "unauthorized"**
- Make sure you're using the authenticated URL with `?token=...`

**Gateway won't start**
- Verify `CLAWDBOT_GATEWAY_TOKEN` is set in `.env`

**LLM connection errors**
- Verify `OPENAI_API_KEY` is valid in `.env`
- Check `OPENAI_BASE_URL` and `OPENAI_MODEL` are correct
- Ensure your account has available credits

## Resources

- [OpenClaw Docs](https://docs.openclaw.ai/)
- [OpenClaw GitHub](https://github.com/openclaw/openclaw)
- [Community Discord](https://discord.com/invite/clawd)
- [Sealos DevBox](https://sealos.io/)

## License

This runtime is provided as-is. OpenClaw is an open-source project with its own license.
