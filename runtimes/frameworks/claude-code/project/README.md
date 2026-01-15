# Next.js + Claude Code + Codex

Production-ready Next.js 14 app with integrated Claude Code Client([Happy](https://github.com/slopus/happy)).

## Setup

### 1. Configure Claude Code API Key

Before using Claude Code, set your API token:

```bash
# Set the token for current session
export ANTHROPIC_AUTH_TOKEN=your_token_here

# Make it persistent (survives restarts)
echo 'export ANTHROPIC_AUTH_TOKEN=your_token_here' >> ~/.bashrc
source ~/.bashrc
```

**Getting your token:**
1. Open **AI Proxy** application in [Sealos](https://os.sealos.io)
2. Click **API Keys** in the left sidebar
3. Click **+New** to create a new API key
4. Copy the generated token

### 2. Download Mobile App

- **iPhone/iPad**: [App Store ](https://apps.apple.com/us/app/happy-claude-code-client/id6748571505)
- **Android**: [Google Play ](https://play.google.com/store/apps/details?id=com.ex3ndr.happy)
- **Web App**: [app.happy.engineering ](https://app.happy.engineering)

### 3. Scan the QR code with your mobile app

```bash
happy --auth # Shows QR code
```

Once you’ve connected your mobile app to your DevBox runtime.

## Self-Host Your Own Happy Server(Optional)

Run your own relay server in minutes on Sealos: https://template.sealos.io/deploy?templateName=happy-server

## Features

- **Next.js 14.2.5** - Server-side rendering, static generation, API routes
- **Happy** - Mobile and Web Client for Claude Code & Codex
- **TypeScript** - Full type safety
- **Hot Reload** - Instant feedback
- **Production Ready** - Optimized build pipeline

## Development

```bash
npm run dev      # Start development server
npm run build    # Create production build
npm run start    # Run production server
npm run lint     # Check code quality
```

## Project Structure

```
.
├── src/              # Application code
├── public/           # Static assets
├── package.json      # Dependencies
├── next.config.mjs   # Next.js config
├── tsconfig.json     # TypeScript config
└── entrypoint.sh     # App launcher
```

## Production Deployment

```bash
bash entrypoint.sh production
```

Creates optimized build and starts production server. Auto-containerizes for Docker deployment.

## Troubleshooting
