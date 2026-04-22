# NestJS v11 Runtime Template

This template provides a server-side application runtime powered by **NestJS 11**, based on the official [TypeScript starter](https://github.com/nestjs/typescript-starter).

## Runtime Summary

- Framework/runtime version: `NestJS 11`
- Base runtime image: `nest.js-v11`
- Entrypoint script: `entrypoint.sh`
- Default service port: `3000`

## Template Files

- `src/main.ts`: application entry point, listens on port `3000`
- `src/app.module.ts`: root module
- `src/app.controller.ts`: root controller with `GET /` route
- `src/app.service.ts`: root service returning "Hello World!"
- `entrypoint.sh`: starts NestJS in dev or production mode

## Run in DevBox

Run commands from `/home/devbox/project`.

### Development mode

```bash
bash entrypoint.sh
```

Behavior:
- Runs `npm install` to ensure dependencies are up to date.
- Starts NestJS with `nest start --watch` for auto-reloading.

### Production mode

```bash
bash entrypoint.sh production
```

Behavior:
- Installs production-only dependencies.
- Builds the project with `npm run build`.
- Starts the application with `node dist/main`.

## Verify Service

```bash
curl http://127.0.0.1:3000
```

## Customization

- Add new modules, controllers, and services under `src/`.
- Update `src/main.ts` to change the listening port or add global middleware.
- Modify `tsconfig.json` for TypeScript compiler options.
