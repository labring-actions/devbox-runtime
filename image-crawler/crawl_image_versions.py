"""Entry point for the DevBox Runtime image crawler."""

from __future__ import annotations

import asyncio
import logging
from dataclasses import replace
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, Iterable, List

import click
from tqdm import tqdm

from config.config import AppConfig, ClientConfig, CONFIG, RetryConfig
from utils.ghcr_client import GHCRClient
from utils.output_formatter import OutputFormatter
from utils.version_parser import ImageVersion, VersionParser
from utils.runtime_inventory import discover_runtime_images

OUTPUT_CHOICES = {"console", "json", "csv"}
SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT = SCRIPT_DIR.parent


def _comma_separated(ctx: click.Context, param: click.Parameter, value: str) -> List[str]:  # noqa: ARG001
    formats = [item.strip().lower() for item in value.split(",") if item.strip()]
    invalid = [fmt for fmt in formats if fmt not in OUTPUT_CHOICES]
    if invalid:
        raise click.BadParameter(f"Unsupported output format(s): {', '.join(invalid)}")
    return list(dict.fromkeys(formats)) or ["console"]


@click.command(context_settings={"help_option_names": ["-h", "--help"]})
@click.option("--output-format", "output_formats", default="console,json,csv", callback=_comma_separated, show_default=True,
              help="Comma separated list of outputs to emit (console,json,csv).")
@click.option("--filter", "filter_pattern", default=None, help="Optional fnmatch-style pattern (matches tag/image/ref).")
@click.option("--concurrent", default=CONFIG.client.concurrent_requests, show_default=True, type=int, help="Concurrent requests to GHCR.")
@click.option("--retry", "retry_attempts", default=CONFIG.client.retry.attempts, show_default=True, type=int,
              help="Number of retry attempts for transient failures.")
@click.option("--repository", default=CONFIG.client.repository, show_default=True, help="Target GHCR repository in org/name format.")
@click.option("--page-size", default=CONFIG.client.page_size, show_default=True, type=int, help="Items fetched per registry/API page.")
@click.option("--throttle", default=CONFIG.client.throttle_rate, show_default=True, type=int, help="Maximum requests per second.")
@click.option("--timeout", default=CONFIG.client.request_timeout, show_default=True, type=int, help="Command timeout (seconds, unused for crane).")
@click.option("--json-path", default=CONFIG.output.json_path, show_default=True, help="Destination path for the JSON artifact.")
@click.option("--csv-path", default=CONFIG.output.csv_path, show_default=True, help="Destination path for the CSV artifact.")
@click.option("--no-color", is_flag=True, default=False, help="Disable colorful console output.")
@click.option("--log-level", default="WARNING", show_default=True, help="Logging level (DEBUG, INFO, WARNING...).")
@click.option("--runtime-root", default="runtimes", show_default=True, help="Directory containing runtime Dockerfiles.")
def main(
    output_formats: List[str],
    filter_pattern: str | None,
    concurrent: int,
    retry_attempts: int,
    repository: str,
    page_size: int,
    throttle: int,
    timeout: int,
    json_path: str,
    csv_path: str,
    no_color: bool,
    log_level: str,
    runtime_root: str,
) -> None:
    logging.basicConfig(level=getattr(logging, log_level.upper(), logging.WARNING), format="%(levelname)s %(name)s: %(message)s")
    client_cfg = ClientConfig(
        base_registry_url=CONFIG.client.base_registry_url,
        repository=repository,
        page_size=page_size,
        concurrent_requests=concurrent,
        request_timeout=timeout,
        throttle_rate=throttle,
        retry=RetryConfig(
            attempts=retry_attempts,
            backoff_factor=CONFIG.client.retry.backoff_factor,
            max_backoff=CONFIG.client.retry.max_backoff,
        ),
    )
    app_config = AppConfig(client=client_cfg, output=replace(CONFIG.output, json_path=json_path, csv_path=csv_path), crawl=CONFIG.crawl)

    runtime_path = _resolve_runtime_root(runtime_root)
    try:
        asyncio.run(run_crawler(app_config, output_formats, filter_pattern, runtime_root=runtime_path, disable_color=no_color))
    except KeyboardInterrupt:
        click.echo("✨ 已取消")


async def run_crawler(
    app_config: AppConfig,
    output_formats: Iterable[str],
    filter_pattern: str | None,
    *,
    runtime_root: Path,
    disable_color: bool,
) -> None:
    parser = VersionParser(app_config.crawl)
    formatter = OutputFormatter(enable_color=not disable_color)
    crawl_started = datetime.utcnow()

    runtime_images = discover_runtime_images(runtime_root)
    if not runtime_images:
        click.echo(f"⚠️ 未在 {runtime_root} 中找到任何 Dockerfile")
        return

    client = GHCRClient(app_config.client)
    with tqdm(desc="爬取镜像标签", unit="tag") as progress_bar:
        tag_infos = await client.get_all_tags(runtime_images, progress_cb=progress_bar.update)
        progress_bar.total = len(tag_infos)
        progress_bar.refresh()

    versions = parser.parse_tags(tag_infos, pattern=filter_pattern)
    metadata = formatter.build_metadata(versions, crawl_started)

    if not versions:
        click.echo("⚠️ 未找到匹配的镜像标签")
        return

    await emit_outputs(formatter, versions, metadata, output_formats, app_config)


async def emit_outputs(
    formatter: OutputFormatter,
    versions: List[ImageVersion],
    metadata: Dict[str, Any],
    output_formats: Iterable[str],
    app_config: AppConfig,
) -> None:
    tasks = []
    for fmt in output_formats:
        if fmt == "console":
            tasks.append(formatter.output_console(versions, metadata))
        elif fmt == "json":
            tasks.append(formatter.output_json(versions, metadata, app_config.output.json_path))
        elif fmt == "csv":
            tasks.append(formatter.output_csv(versions, app_config.output.csv_path))
    await asyncio.gather(*tasks)


def _resolve_runtime_root(user_value: str) -> Path:
    candidate = Path(user_value)
    if candidate.is_absolute():
        return candidate
    first_try = (Path.cwd() / candidate).resolve()
    if first_try.exists():
        return first_try
    fallback = (REPO_ROOT / candidate).resolve()
    return fallback


if __name__ == "__main__":
    main()
