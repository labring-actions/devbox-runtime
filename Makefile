# DevBox Runtime Makefile
# This Makefile provides targets for building, testing, and managing the runtimectl tool

# Variables
BINARY_NAME=runtimectl
TOOL_DIR=tool
BUILD_DIR=bin
GO_VERSION=1.21
VERSION=1.0.0
LDFLAGS=-ldflags "-X main.Version=$(VERSION) -X main.BuildTime=$(shell date -u '+%Y-%m-%d_%H:%M:%S')"

# Default target
.PHONY: help
help: ## Show this help message
	@echo "DevBox Runtime Makefile"
	@echo "======================="
	@echo ""
	@echo "Available targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Build targets
.PHONY: build
build: ## Build the runtimectl binary
	@echo "Building $(BINARY_NAME)..."
	@mkdir -p $(BUILD_DIR)
	@cd $(TOOL_DIR) && go build $(LDFLAGS) -o ../$(BUILD_DIR)/$(BINARY_NAME) ./cmd

.PHONY: build-linux
build-linux: ## Build the runtimectl binary for Linux
	@echo "Building $(BINARY_NAME) for Linux..."
	@mkdir -p $(BUILD_DIR)
	@cd $(TOOL_DIR) && GOOS=linux GOARCH=amd64 go build $(LDFLAGS) -o ../$(BUILD_DIR)/$(BINARY_NAME)-linux ./cmd

.PHONY: build-windows
build-windows: ## Build the runtimectl binary for Windows
	@echo "Building $(BINARY_NAME) for Windows..."
	@mkdir -p $(BUILD_DIR)
	@cd $(TOOL_DIR) && GOOS=windows GOARCH=amd64 go build $(LDFLAGS) -o ../$(BUILD_DIR)/$(BINARY_NAME)-windows.exe ./cmd

.PHONY: build-darwin
build-darwin: ## Build the runtimectl binary for macOS
	@echo "Building $(BINARY_NAME) for macOS..."
	@mkdir -p $(BUILD_DIR)
	@cd $(TOOL_DIR) && GOOS=darwin GOARCH=amd64 go build $(LDFLAGS) -o ../$(BUILD_DIR)/$(BINARY_NAME)-darwin ./cmd

.PHONY: build-all
build-all: build-linux build-windows build-darwin ## Build binaries for all platforms

# Development targets
.PHONY: dev
dev: build ## Build and install for development
	@echo "Installing $(BINARY_NAME) for development..."
	@cp $(BUILD_DIR)/$(BINARY_NAME) /usr/local/bin/$(BINARY_NAME) || echo "Failed to install to /usr/local/bin, you may need sudo"

.PHONY: clean
clean: ## Clean build artifacts
	@echo "Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR)
	@cd $(TOOL_DIR) && go clean

.PHONY: clean-all
clean-all: clean ## Clean all artifacts including Go cache
	@echo "Cleaning all artifacts..."
	@cd $(TOOL_DIR) && go clean -cache -modcache -testcache

# Testing targets
.PHONY: test
test: ## Run tests
	@echo "Running tests..."
	@cd $(TOOL_DIR) && go test -v ./...

.PHONY: test-coverage
test-coverage: ## Run tests with coverage
	@echo "Running tests with coverage..."
	@cd $(TOOL_DIR) && go test -v -coverprofile=coverage.out ./...
	@cd $(TOOL_DIR) && go tool cover -html=coverage.out -o coverage.html
	@echo "Coverage report generated: $(TOOL_DIR)/coverage.html"

.PHONY: test-race
test-race: ## Run tests with race detection
	@echo "Running tests with race detection..."
	@cd $(TOOL_DIR) && go test -race -v ./...

# Code quality targets
.PHONY: fmt
fmt: ## Format Go code
	@echo "Formatting Go code..."
	@cd $(TOOL_DIR) && go fmt ./...

.PHONY: vet
vet: ## Run go vet
	@echo "Running go vet..."
	@cd $(TOOL_DIR) && go vet ./...

.PHONY: lint
lint: ## Run golangci-lint
	@echo "Running golangci-lint..."
	@cd $(TOOL_DIR) && golangci-lint run

.PHONY: check
check: fmt vet lint test ## Run all code quality checks

# Dependency management
.PHONY: deps
deps: ## Download dependencies
	@echo "Downloading dependencies..."
	@cd $(TOOL_DIR) && go mod download

.PHONY: deps-update
deps-update: ## Update dependencies
	@echo "Updating dependencies..."
	@cd $(TOOL_DIR) && go get -u ./...
	@cd $(TOOL_DIR) && go mod tidy

.PHONY: deps-vendor
deps-vendor: ## Vendor dependencies
	@echo "Vendoring dependencies..."
	@cd $(TOOL_DIR) && go mod vendor

# Runtime management targets
.PHONY: scan
scan: build ## Scan runtime packages
	@echo "Scanning runtime packages..."
	@./$(BUILD_DIR)/$(BINARY_NAME) scan

.PHONY: list
list: build ## List all runtime packages
	@echo "Listing all runtime packages..."
	@./$(BUILD_DIR)/$(BINARY_NAME) list

.PHONY: validate
validate: build ## Validate runtime packages
	@echo "Validating runtime packages..."
	@./$(BUILD_DIR)/$(BINARY_NAME) validate

.PHONY: generate-meta
generate-meta: build ## Generate runtime metadata
	@echo "Generating runtime metadata..."
	@./$(BUILD_DIR)/$(BINARY_NAME) generate-meta

# CI/CD targets
.PHONY: ci-build-matrix
ci-build-matrix: build ## Generate CI build matrix
	@echo "Generating CI build matrix..."
	@./$(BUILD_DIR)/$(BINARY_NAME) ci build-matrix

.PHONY: ci-generate-config
ci-generate-config: build ## Generate runtime configuration
	@echo "Generating runtime configuration..."
	@./$(BUILD_DIR)/$(BINARY_NAME) ci generate-config

.PHONY: ci-generate-config-cn
ci-generate-config-cn: build ## Generate runtime configuration for CN
	@echo "Generating runtime configuration for CN..."
	@./$(BUILD_DIR)/$(BINARY_NAME) ci generate-config --cn

.PHONY: ci-analyze-dependencies
ci-analyze-dependencies: build ## Analyze package dependencies
	@echo "Analyzing package dependencies..."
	@./$(BUILD_DIR)/$(BINARY_NAME) ci analyze-dependencies

.PHONY: ci-build-order
ci-build-order: build ## Get build order based on dependencies
	@echo "Getting build order..."
	@./$(BUILD_DIR)/$(BINARY_NAME) ci build-order

.PHONY: ci-dependency-graph
ci-dependency-graph: build ## Generate dependency graph
	@echo "Generating dependency graph..."
	@./$(BUILD_DIR)/$(BINARY_NAME) ci dependency-graph

# Docker targets
.PHONY: docker-build
docker-build: ## Build Docker image for runtimectl
	@echo "Building Docker image..."
	@docker build -t runtimectl:$(VERSION) -f Dockerfile.tool .

.PHONY: docker-run
docker-run: ## Run runtimectl in Docker
	@echo "Running runtimectl in Docker..."
	@docker run --rm -v $(PWD):/workspace -w /workspace runtimectl:$(VERSION)

# Release targets
.PHONY: release-prep
release-prep: clean test build-all ## Prepare for release
	@echo "Preparing release..."
	@mkdir -p release
	@cp $(BUILD_DIR)/$(BINARY_NAME)-linux release/
	@cp $(BUILD_DIR)/$(BINARY_NAME)-windows.exe release/
	@cp $(BUILD_DIR)/$(BINARY_NAME)-darwin release/
	@echo "Release artifacts prepared in release/ directory"

.PHONY: release-tar
release-tar: release-prep ## Create release tarballs
	@echo "Creating release tarballs..."
	@cd release && tar -czf $(BINARY_NAME)-linux-$(VERSION).tar.gz $(BINARY_NAME)-linux
	@cd release && tar -czf $(BINARY_NAME)-darwin-$(VERSION).tar.gz $(BINARY_NAME)-darwin
	@cd release && zip $(BINARY_NAME)-windows-$(VERSION).zip $(BINARY_NAME)-windows.exe
	@echo "Release tarballs created in release/ directory"

# Installation targets
.PHONY: install
install: build ## Install runtimectl to system
	@echo "Installing $(BINARY_NAME)..."
	@sudo cp $(BUILD_DIR)/$(BINARY_NAME) /usr/local/bin/
	@sudo chmod +x /usr/local/bin/$(BINARY_NAME)
	@echo "$(BINARY_NAME) installed to /usr/local/bin/"

.PHONY: uninstall
uninstall: ## Uninstall runtimectl from system
	@echo "Uninstalling $(BINARY_NAME)..."
	@sudo rm -f /usr/local/bin/$(BINARY_NAME)
	@echo "$(BINARY_NAME) uninstalled"

# Development workflow
.PHONY: dev-setup
dev-setup: deps fmt vet ## Setup development environment
	@echo "Development environment setup complete"

.PHONY: pre-commit
pre-commit: fmt vet test ## Run pre-commit checks
	@echo "Pre-commit checks completed"

.PHONY: ci
ci: check build test-coverage ## Run CI pipeline
	@echo "CI pipeline completed"

# Utility targets
.PHONY: version
version: build ## Show version information
	@./$(BUILD_DIR)/$(BINARY_NAME) --version

.PHONY: info
info: ## Show build information
	@echo "Build Information:"
	@echo "  Binary: $(BINARY_NAME)"
	@echo "  Version: $(VERSION)"
	@echo "  Go Version: $(GO_VERSION)"
	@echo "  Tool Directory: $(TOOL_DIR)"
	@echo "  Build Directory: $(BUILD_DIR)"

# Default target
.DEFAULT_GOAL := help
