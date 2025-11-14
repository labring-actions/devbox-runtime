# DevBox Runtime Image Crawler

An asynchronous crawler that enumerates every image tag published under `ghcr.io/labring-actions/devbox`, highlights tags that start with `v`, categorises them by runtime type, and emits colourful console output alongside JSON and CSV artifacts. Tags that do **not** begin with `v` are ignored entirely to keep the dataset focused on semantically versioned releases.

## Features

- Async GHCR + GitHub Packages client with retry, throttling, and pagination support
- Classification by OS / language / framework / service heuristics
- Semantic version detection with explicit emphasis on tags beginning with `v`
- Output strictly filtered to tags whose names start with `v`
- Optional `--latest-only` mode keeps just the newest semantic version per image (and its `-cn` variant)
- Rich console progress indicators powered by `tqdm`
- Multi-format persistence: JSON + CSV located under `output/`
- Resilient error handling (automatic retries, rate-limit awareness, graceful fallbacks)

## Getting Started

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
# Install crane: https://github.com/google/go-containerregistry/tree/main/cmd/crane
#   macOS (Homebrew): brew install go-containerregistry
python crawl_image_versions.py --output-format console,json,csv

# 仅查看最新版本（含 -cn 镜像）
python crawl_image_versions.py --latest-only --output-format console
```

The crawler discovers image names from the `runtimes/` directory and shells out to `crane ls` for each of them, so make sure `crane` is available on your `PATH`.

Run `python crawl_image_versions.py --help` for the full list of CLI switches.
