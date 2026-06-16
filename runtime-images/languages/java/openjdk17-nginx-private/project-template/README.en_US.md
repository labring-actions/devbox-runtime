# JDK 17 + Nginx Private Runtime Template

This template targets private deployment scenarios. It provides an **OpenJDK 17** application runtime with **Nginx 1.22.1** as the front HTTP entrypoint.

## Runtime Summary

- Language/runtime version: `OpenJDK 17`
- Web entrypoint: `Nginx 1.22.1`
- Base runtime image: `java-openjdk17-nginx-private`
- Entrypoint script: `entrypoint.sh`
- Default public service port: `8080`
- Default Java app port: `18080` (bound to `127.0.0.1` only)

## Template Files

- `HelloWorld.java`: Java HTTP service using `com.sun.net.httpserver`
- `nginx.conf`: project-level Nginx server block that proxies `8080` to the Java app
- `entrypoint.sh`: compiles the Java app, starts the backend process, and starts Nginx in foreground

## Run in DevBox

Run commands from `/home/devbox/project`.

### Development mode

```bash
bash entrypoint.sh
```

Behavior:
- Compiles the app with `javac HelloWorld.java`.
- Starts the Java service on `127.0.0.1:18080`.
- Validates the Nginx config and starts Nginx on `0.0.0.0:8080`.

### Production mode

```bash
bash entrypoint.sh production
```

Behavior:
- Uses the same startup path as development mode so private deployments keep a single entrypoint.

## Verify Service

```bash
curl http://127.0.0.1:8080
```

Expected output:

```text
Hello from JDK 17 behind Nginx
```

## Customization

- Replace `HelloWorld.java` with your application or framework entrypoint.
- To change the backend port, update both `JAVA_APP_PORT` and `proxy_pass` in `nginx.conf`.
- Extend `nginx.conf` with TLS termination, reverse proxy, caching, static assets, or private deployment routing rules.
