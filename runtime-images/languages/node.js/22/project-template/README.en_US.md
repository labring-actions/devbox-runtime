# Node.js 22 Runtime Template

This template provides a minimal Node.js HTTP service for DevBox runtime **Node.js 22**.

## Runtime Summary

- Language version: `Node.js 22`
- Base runtime image: `node.js-22`
- Entrypoint script: `entrypoint.sh`
- Default service port: `8080`

## Template Files

- `hello_world.js`: HTTP server using Node built-in `http`
- `entrypoint.sh`: startup script with environment mode switch

## Run in DevBox

Run commands from `/home/devbox/project`.

### Development mode

```bash
bash entrypoint.sh
```

Behavior:
- Starts service with `NODE_ENV=development node hello_world.js`.

### Production mode

```bash
bash entrypoint.sh production
```

Behavior:
- Starts service with `NODE_ENV=production node hello_world.js`.

## Verify Service

```bash
curl http://127.0.0.1:8080
```

Expected output:

```text
Hello World!
```

## Customization

- Replace `hello_world.js` with your app entry (Express/Fastify/Nest, etc.).
- Keep `entrypoint.sh` aligned with your actual start command.
- Add dependency install/build steps when migrating to package-based projects.
