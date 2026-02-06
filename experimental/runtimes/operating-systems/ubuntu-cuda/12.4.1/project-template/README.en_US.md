# Ubuntu CUDA 12.4.1 Runtime Template

This template provides a minimal **GPU-ready operating-system runtime** based on Ubuntu CUDA 12.4.1.
Use it when you need CUDA libraries available before adding your own AI/compute stack.

## Runtime Summary

- OS/CUDA version: `ubuntu-cuda-12.4.1`
- Base runtime image: `ubuntu-cuda-12.4.1`
- Entrypoint script: `entrypoint.sh`
- Default service port: `8080`

## Template Files

- `entrypoint.sh`: creates a static `index.html` and starts `busybox httpd`

## Run in DevBox

Run commands from `/home/devbox/project`.

```bash
bash entrypoint.sh
```

Behavior:
- Uses `PORT` environment variable when provided, defaults to `8080`.
- Serves files from `/home/devbox/project/www`.

## Verify Service

```bash
curl http://127.0.0.1:8080
```

Expected output:

```text
Hello, World!
```

## Customization

- Install CUDA-dependent frameworks (for example PyTorch, TensorFlow, custom CUDA apps).
- Replace `entrypoint.sh` with your own startup logic for model services or workers.
- Ensure GPU scheduling and exposed ports are configured as required by your workload.
