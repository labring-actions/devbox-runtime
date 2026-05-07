# Runtime Image Conformance

This workflow validates already-published runtime images. It does not build images.

Run it from **Runtime Image Conformance**, provide the base tag without the localization suffix, and the workflow expands the matrix as:

- runtime Dockerfile under `runtime-images/**/Dockerfile`
- localization tag suffix: `en-us`, `zh-cn`, or both
- architecture: `amd64`, `arm64`, or both

The image reference is generated as:

```text
ghcr.io/<owner>/devbox-runtime-images/<runtime-name>-<runtime-version>:<tag>-<l10n>
```

## Test Coverage

All non-sandbox runtimes share these checks:

- `devbox` user exists.
- `/home/devbox/project` exists and is writable by `devbox`.
- `README.md` matches `project-template/README.<L10N>.md`.
- `README.s6-user-guide.md` matches the localized tooling doc when present.
- localized README source files are not left in the final project directory.
- `entrypoint.sh` exists.
- the entrypoint is started once as root, then the legacy smoke script is run as `devbox` to catch root-created output and permission pollution.

Runtime-specific checks:

| Runtime | Checks |
| --- | --- |
| `operating-systems/debian/12.6` | Debian identity, busybox, localized README, root/devbox entrypoint order |
| `operating-systems/ubuntu/22.04` | Ubuntu identity, busybox, localized README, root/devbox entrypoint order |
| `operating-systems/ubuntu-cuda/12.4.1` | Ubuntu identity, CUDA compiler/runtime presence, busybox, localized README, root/devbox entrypoint order |
| `languages/c/gcc-12.2.0` | GCC version, C template, compile/server smoke, root/devbox entrypoint order |
| `languages/cpp/gcc-12.2.0` | G++ version, C++ template, compile/server smoke, root/devbox entrypoint order |
| `languages/go/1.22.5` | exact Go version, prebuilt binary, `GOPROXY` for `zh_CN`, writable Go cache, root/devbox entrypoint order |
| `languages/go/1.23.0` | exact Go version, prebuilt binary, `GOPROXY` for `zh_CN`, writable Go cache, root/devbox entrypoint order |
| `languages/java/openjdk17` | Java/Javac 17, UTF-8, Maven mirror for `zh_CN`, root/devbox entrypoint order |
| `languages/net/8.0` | .NET 8 prefix, NuGet mirror sources for `zh_CN`, no `nuget.org` source for `zh_CN`, root/devbox entrypoint order |
| `languages/net/10.0` | .NET 10 prefix, NuGet mirror sources for `zh_CN`, no `nuget.org` source for `zh_CN`, root/devbox entrypoint order |
| `languages/node.js/18` | Node 18, npm/yarn/pnpm, npm mirror for `zh_CN`, root/devbox entrypoint order |
| `languages/node.js/20` | Node 20, npm/yarn/pnpm, npm mirror for `zh_CN`, root/devbox entrypoint order |
| `languages/node.js/22` | Node 22, npm/yarn/pnpm, npm mirror for `zh_CN`, root/devbox entrypoint order |
| `languages/php/7.4` | PHP 7.4, Composer, PHP Redis/MongoDB extensions, Composer mirror for `zh_CN`, root/devbox entrypoint order |
| `languages/php/8.2` | PHP 8.2, Composer, PHP Redis/MongoDB extensions, Composer mirror for `zh_CN`, root/devbox entrypoint order |
| `languages/python/3.10` | Python 3.10, pip, pip mirror for `zh_CN`, root/devbox entrypoint order |
| `languages/python/3.11` | Python 3.11, pip, pip mirror for `zh_CN`, root/devbox entrypoint order |
| `languages/python/3.12` | Python 3.12, pip, pip mirror for `zh_CN`, root/devbox entrypoint order |
| `languages/rust/1.81.0` | Rust/Cargo 1.81.0, Cargo mirror for `zh_CN`, Cargo template, root/devbox entrypoint order |
| `frameworks/nest.js/v11` | Node 20, Nest CLI, npm mirror for `zh_CN`, build output, root/devbox entrypoint order |
| `frameworks/nginx/1.22.1` | Nginx 1.22.1, config test, `/tmp/nginx-devbox` runtime paths, no distro default include pollution, root/devbox entrypoint order |
| `frameworks/openclaw/latest` | Node 22, OpenClaw, Clawhub, Bun, npm mirror for `zh_CN`, safe `.env.example`, root/devbox entrypoint order |
| `frameworks/sandbox/v1` | workspace ownership, codex-gateway, Codex CLI, Node/npm, Python/pip, kubectl, helm, bun, ripgrep, bubblewrap, npm/pip mirrors for `zh_CN` |
