# PHP 8.2 Runtime Template

This template provides a minimal PHP HTTP service for DevBox runtime **PHP 8.2**.

## Runtime Summary

- Language version: `PHP 8.2`
- Base runtime image: `php-8.2`
- Entrypoint script: `entrypoint.sh`
- Default service port: `8080`

## Template Files

- `hello_world.php`: sample response script
- `entrypoint.sh`: starts PHP built-in web server for different modes

## Run in DevBox

Run commands from `/home/devbox/project`.

### Development mode

```bash
bash entrypoint.sh
```

Behavior:
- Runs `php -S 0.0.0.0:8080 hello_world.php`
- Enables error logging parameters for development troubleshooting.

### Production mode

```bash
bash entrypoint.sh production
```

Behavior:
- Runs the same built-in server on port `8080`
- Enables `opcache` related options for production-like performance.

## Verify Service

```bash
curl http://127.0.0.1:8080
```

Expected output:

```text
Hello, World!
```

## Customization

- Replace `hello_world.php` with your real application entry.
- If using frameworks (Laravel/Symfony), update the command in `entrypoint.sh`.
- Align PHP ini options in entrypoint with your runtime requirements.
