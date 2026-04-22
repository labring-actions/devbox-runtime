# Python 3.11 Runtime Template

This template provides a minimal Python HTTP service for DevBox runtime **Python 3.11**.

## Runtime Summary

- Language version: `Python 3.11`
- Base runtime image: `python-3.11`
- Entrypoint script: `entrypoint.sh`
- Default service port: `8080`

## Template Files

- `hello.py`: HTTP server implemented with `http.server`
- `entrypoint.sh`: startup script for development/production modes

## Run in DevBox

Run commands from `/home/devbox/project`.

### Development mode

```bash
bash entrypoint.sh
```

Behavior:
- If `bin/activate` exists, it is sourced first.
- Starts the app with `python3 hello.py`.

### Production mode

```bash
bash entrypoint.sh production
```

Behavior:
- Uses the same startup command (`python3 hello.py`) for a deterministic runtime path.

## Verify Service

After startup, check the endpoint:

```bash
curl http://127.0.0.1:8080
```

Expected output:

```text
Hello, World!
```

## Customization

- Update `hello.py` to add routes or business logic.
- Replace `entrypoint.sh` if you need process managers (for example `gunicorn` or `uvicorn`).
- Keep container exposed port and app listen port consistent.
