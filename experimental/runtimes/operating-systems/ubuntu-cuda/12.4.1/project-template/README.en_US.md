# Quick Start

> This guide explains how to create, develop, and deploy a Next.js app with Sealos Devbox, including remote development via Cursor IDE and cloud deployment.

## Create a Devbox project

1. Open Sealos Desktop → Devbox → New Project.
2. Choose Next.js as the framework; set CPU and memory.
![quick-start-1](https://github.com/labring/sealos/blob/main/docs/5.0/i18n/en/user-guide/devbox/images/quick-start-1.png?raw=true)
3. Network:
   - Expose port 3000 (Next.js default).
   - Enable public access (auto-random domain) or set a custom domain.
   > Keep the exposed port consistent with your Next.js config.
![quick-start-2](https://github.com/labring/sealos/blob/main/docs/5.0/i18n/en/user-guide/devbox/images/quick-start-2.png?raw=true)
4. Click Create.

## Connect Cursor IDE

- Find your Devbox project in the list; choose IDE from the dropdown.
![quick-start-3](https://github.com/labring/sealos/blob/main/docs/5.0/i18n/en/user-guide/devbox/images/quick-start-3.png?raw=true)
1. Launch local Cursor IDE (select Cursor in the dropdown).
2. Cursor prompts to install the Devbox plugin, then connects via SSH.  
   > You can switch to VSCode / Insiders / Cursor / Windsurf anytime.

## Develop

1. After Cursor connects, edit files directly in the remote workspace.
![quick-start-4](https://github.com/labring/sealos/blob/main/docs/5.0/i18n/en/user-guide/devbox/images/quick-start-4.png?raw=true)
   > Remote dev keeps env parity; accessible from any Cursor-installed device.
2. Debug Next.js:
   ```bash
   npm run dev
   ```
3. Access the running app:
   - In Sealos Devbox UI, open project details → click the public URL.
![quick-start-5](https://github.com/labring/sealos/blob/main/docs/5.0/i18n/en/user-guide/devbox/images/quick-start-5.png?raw=true)
4. See your Next.js page:
![quick-start-6](https://github.com/labring/sealos/blob/main/docs/5.0/i18n/en/user-guide/devbox/images/quick-start-6.png?raw=true)

## Release

1. In Cursor terminal:
   ```bash
   npm run build
   ```
2. In project details → Version History → Publish Version.
3. Fill image name (pre-filled), version (e.g., v1.0), description.
![quick-start-7](https://github.com/labring/sealos/blob/main/docs/5.0/i18n/en/user-guide/devbox/images/quick-start-7.png?raw=true)
4. After publish, the version appears with status/time/description.
![quick-start-8](https://github.com/labring/sealos/blob/main/docs/5.0/i18n/en/user-guide/devbox/images/quick-start-8.png?raw=true)
> Each release snapshots your code for versioning and rollback.

## Deploy

1. In Version History, pick a version → Deploy.
2. Configure in the Sealos App console:
   - App name, resources (CPU/Mem), env vars, volumes.
![quick-start-9](https://github.com/labring/sealos/blob/main/docs/5.0/i18n/en/user-guide/devbox/images/quick-start-9.png?raw=true)
3. Click Deploy.
4. When status is “running”, click Public Address to open the app.
![quick-start-10](https://github.com/labring/sealos/blob/main/docs/5.0/i18n/en/user-guide/devbox/images/quick-start-10.png?raw=true)

This workflow lets you develop/debug in cloud while using local IDE, and share the app via public URL.

