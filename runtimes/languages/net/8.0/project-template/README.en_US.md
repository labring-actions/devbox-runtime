# .NET 8.0 Runtime Template

This template provides a minimal ASP.NET Core service for DevBox runtime **.NET 8.0**.

## Runtime Summary

- Language/runtime version: `.NET 8.0`
- Base runtime image: `net-8.0`
- Entrypoint script: `entrypoint.sh`
- Default service port: `8080`

## Template Files

- `Program.cs`: minimal API application
- `hello_world.csproj`: project definition
- `entrypoint.sh`: development/production startup logic
- `hello_world.http`: sample request file for local testing

## Run in DevBox

Run commands from `/home/devbox/project`.

### Development mode

```bash
bash entrypoint.sh
```

Behavior:
- Starts with `dotnet run`.

### Production mode

```bash
bash entrypoint.sh production
```

Behavior:
- Publishes in Release mode: `dotnet publish -c Release`
- Runs published app: `dotnet ./bin/Release/net8.0/publish/hello_world.dll`

## Verify Service

```bash
curl http://127.0.0.1:8080
```

Expected output:

```text
Hello, World
```

## Customization

- Add routes/services in `Program.cs`.
- Update project metadata and dependencies in `hello_world.csproj`.
- Keep publish output path in `entrypoint.sh` synchronized with target framework changes.
