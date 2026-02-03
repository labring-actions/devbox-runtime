# Clawdbot Runtime

This Devbox runtime installs Clawdbot globally via npm and provides a simple entrypoint for the gateway.

## Quick Start

1. Export required environment variables (examples):

```bash
export CLAWDBOT_GATEWAY_TOKEN=your-token
export OPENAI_API_KEY=sk-...
```

2. Start the gateway:

```bash
bash entrypoint.sh
```

3. Get the dashboard URL:

```bash
clawdbot dashboard --no-open
```

## Notes

- Config is stored at `~/.clawdbot`.
- Workspace is stored at `~/workspace`.
- The auto-approve helper runs in the background when using `entrypoint.sh`.
