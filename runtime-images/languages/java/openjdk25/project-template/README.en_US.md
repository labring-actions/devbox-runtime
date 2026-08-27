# Java OpenJDK 25 Runtime Template

This template provides a minimal Java HTTP service for the DevBox **OpenJDK 25** runtime. The image uses Eclipse Temurin OpenJDK `25.0.4.1+1` and Apache Maven `3.9.16`.

## Runtime Summary

- Language/runtime version: `Eclipse Temurin OpenJDK 25.0.4.1+1`
- Build tool: `Apache Maven 3.9.16`
- Base runtime image: `java-openjdk25`
- Entrypoint script: `entrypoint.sh`
- Default service port: `8080`

## Template Files

- `HelloWorld.java`: HTTP service using `com.sun.net.httpserver`
- `entrypoint.sh`: compile-and-run script for development and production modes

## Run in DevBox

Run commands from `/home/devbox/project`.

### Development mode

```bash
bash entrypoint.sh
```

### Production mode

```bash
bash entrypoint.sh production
```

Both modes compile the application with JDK 25 and start it with `java HelloWorld`.

## Verify Service

```bash
curl http://127.0.0.1:8080
```

Expected output:

```text
Hello, World!
```

## Customization

- Split `HelloWorld.java` into a package-based structure for larger projects.
- Use the included Maven installation when dependency management is needed.
- Replace the entrypoint commands when switching to a packaged JAR or framework-based application.
