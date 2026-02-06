# Java OpenJDK 17 Runtime Template

This template provides a minimal Java HTTP service for DevBox runtime **OpenJDK 17**.

## Runtime Summary

- Language/runtime version: `OpenJDK 17`
- Base runtime image: `java-openjdk17`
- Entrypoint script: `entrypoint.sh`
- Default service port: `8080`

## Template Files

- `HelloWorld.java`: HTTP service using `com.sun.net.httpserver`
- `entrypoint.sh`: compile-and-run script for both modes

## Run in DevBox

Run commands from `/home/devbox/project`.

### Development mode

```bash
bash entrypoint.sh
```

Behavior:
- Compiles with `javac HelloWorld.java`
- Runs with `java HelloWorld`

### Production mode

```bash
bash entrypoint.sh production
```

Behavior:
- Uses the same compile-and-run flow for deterministic execution.

## Verify Service

```bash
curl http://127.0.0.1:8080
```

Expected output:

```text
Hello, World!
```

## Customization

- Split `HelloWorld.java` into package-based structure for larger projects.
- Introduce Maven/Gradle if dependency management is needed.
- Replace entrypoint commands when switching to fat-jar or framework-based startup.
