## Pure Debian Environment Example (Next.js)

This is a “pure Debian 12” development environment on Sealos. It shows how to quickly set up and run a Next.js app inside a clean Debian system. The workflow feels just like local development—no need to manage Docker yourself.

### Project Description
The project provides a minimal yet practical developer experience: once in Devbox, install Node.js (via nvm) and create a Next.js sample. You can extend it to your own stack as needed.

### Environment
- OS: Debian 12 (bookworm)
- Platform: Sealos Devbox (cloud-based, ready to use)
- User & Privileges: default user `devbox` with passwordless `sudo`
- Networking & SSH: `sshd` enabled, public key login supported
- Package Mirrors: Tsinghua mirror (CN) supported for faster installs in Mainland China

### Project Execution
- Development mode (recommended): enter Devbox, then install Node.js (nvm) and run Next.js dev server.
```bash
# 1) Install nvm (recommended)
curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

# 2) Install & use Node.js LTS (includes npm)
nvm install --lts && nvm use --lts

# 3) Create and start a Next.js sample
npx create-next-app@latest my-next-app
cd my-next-app
npm run dev  # default port 3000
```
- Access: open the project’s public URL in Devbox, and make sure the port is set to 3000.

- Production mode (optional): after development, build and run in production mode.
```bash
npm run build
npm run start
```

### Devbox: Code. Run. Ship. We handle the rest.
DevBox: Code. Build. Deploy. We've Got the Rest. With DevBox, you can focus entirely on writing great code while we handle the infrastructure, scaling, and deployment. Seamless development from start to production.