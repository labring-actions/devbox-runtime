# Next.js v16 Runtime Template

This template provides a React web application runtime powered by **Next.js 16** using the App Router and TypeScript.

## Runtime Summary

- Framework/runtime version: `Next.js 16`
- Base runtime image: `next.js-v16`
- Entrypoint script: `entrypoint.sh`
- Default service port: `3000`

## Template Files

- `app/layout.tsx`: root layout and page metadata
- `app/page.tsx`: default homepage rendered by the App Router
- `app/globals.css`: shared application styles
- `next.config.ts`: Next.js configuration
- `tsconfig.json`: TypeScript compiler configuration
- `entrypoint.sh`: starts Next.js in dev or production mode

## Run in DevBox

Run commands from `/home/devbox/project`.

### Development mode

```bash
bash entrypoint.sh
```

Behavior:
- Runs `npm install` to ensure dependencies are up to date.
- Starts `next dev` on `0.0.0.0:3000` for hot reloading.

### Production mode

```bash
bash entrypoint.sh production
```

Behavior:
- Installs dependencies needed for the production build.
- Builds the project with `npm run build`.
- Prunes development dependencies after the build.
- Starts `next start` on `0.0.0.0:3000`.

## Verify Service

```bash
curl http://127.0.0.1:3000
```

## Customization

- Edit `app/page.tsx` to change the default page.
- Add routes by creating folders under `app/`.
- Update `app/globals.css` for shared styling.
- Modify `next.config.ts` for framework options such as image domains or build output.
