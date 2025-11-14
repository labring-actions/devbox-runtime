"""Configuration values for the DevBox Runtime image crawler."""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import List


@dataclass
class RetryConfig:
    attempts: int = 3
    backoff_factor: float = 1.5
    max_backoff: float = 20.0


@dataclass
class ClientConfig:
    base_registry_url: str = "https://ghcr.io/v2"
    repository: str = "labring-actions/devbox"
    page_size: int = 100
    concurrent_requests: int = 10
    request_timeout: int = 30
    throttle_rate: int = 10  # req/sec limit safeguard
    retry: RetryConfig = field(default_factory=RetryConfig)


@dataclass
class OutputConfig:
    console: bool = True
    json_path: str = "output/versions.json"
    csv_path: str = "output/versions.csv"
    color: bool = True


@dataclass
class CrawlConfig:
    categories: dict[str, List[str]] = field(
        default_factory=lambda: {
            "os": ["debian-", "ubuntu-", "alpine-"],
            "language": ["python-", "go-", "node-", "java-", "php-", "rust-", "cpp-", "dotnet-"],
            "framework": ["django-", "flask-", "react-", "vue-", "angular-", "express-", "spring-"],
            "service": ["mcp-", "nginx-", "redis-", "mysql-"],
        }
    )
    default_category: str = "other"


@dataclass
class AppConfig:
    client: ClientConfig = field(default_factory=ClientConfig)
    output: OutputConfig = field(default_factory=OutputConfig)
    crawl: CrawlConfig = field(default_factory=CrawlConfig)


CONFIG = AppConfig()
