# DevBox Runtime Tool

This directory contains the `runtimectl` command-line tool for managing DevBox runtime packages.

## Structure

```
tool/
├── cmd/           # Command-line interface code
│   ├── main.go    # Main entry point
│   └── commands.go # Command implementations
├── api/           # Runtime management API
├── go.mod         # Go module definition
├── go.sum         # Go module checksums
└── README.md      # This file
```

## Building

From the project root:

```bash
# Build the tool
make build

# Build for all platforms
make build-all

# Install for development
make dev
```

## Usage

```bash
# List all packages
runtimectl list

# List frameworks
runtimectl list-frameworks

# Show package info
runtimectl info vue v3.4.29

# Scan packages
runtimectl scan

# Generate metadata
runtimectl generate-meta

# CI commands
runtimectl ci build-matrix
runtimectl ci generate-config
```

## Development

```bash
# Setup development environment
make dev-setup

# Run tests
make test

# Run code quality checks
make check

# Format code
make fmt
```

## Docker

```bash
# Build Docker image
make docker-build

# Run in Docker
make docker-run
```
