package main

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"text/tabwriter"

	"github.com/labring-actions/devbox-runtime/tool/api"
)

func (cli *CLI) listAllPackages() error {
	if err := cli.manager.ScanPackages(); err != nil {
		return fmt.Errorf("failed to scan packages: %w", err)
	}

	if cli.outputFormat == "json" {
		// Convert map to slice for JSON output
		var packages []*api.PackageInfo
		for _, pkg := range cli.manager.Packages {
			packages = append(packages, pkg)
		}
		return cli.outputPackagesJSON(packages)
	}

	// Group packages by kind
	kinds := []string{"framework", "language", "os", "service"}
	for _, kind := range kinds {
		packages := cli.manager.ListPackages(kind)
		if len(packages) > 0 {
			fmt.Printf("\n=== %s Packages ===\n", strings.Title(kind))
			cli.outputPackagesTable(packages)
		}
	}

	return nil
}

func (cli *CLI) listPackages(kind string) error {
	if err := cli.manager.ScanPackages(); err != nil {
		return fmt.Errorf("failed to scan packages: %w", err)
	}

	packages := cli.manager.ListPackages(kind)

	if cli.outputFormat == "json" {
		return cli.outputPackagesJSON(packages)
	}

	fmt.Printf("=== %s Packages ===\n", strings.Title(kind))
	cli.outputPackagesTable(packages)
	return nil
}

func (cli *CLI) showPackageInfo(name, version string) error {
	if err := cli.manager.ScanPackages(); err != nil {
		return fmt.Errorf("failed to scan packages: %w", err)
	}

	// Find package
	var pkg *api.PackageInfo
	var err error

	if version != "" {
		pkg, err = cli.manager.GetPackage(name, version)
	} else {
		// Find latest version
		packages := cli.manager.ListPackages("")
		for _, p := range packages {
			if p.Name == name {
				if pkg == nil || p.Version > pkg.Version {
					pkg = p
				}
			}
		}
		if pkg == nil {
			err = fmt.Errorf("package %s not found", name)
		}
	}

	if err != nil {
		return err
	}

	if cli.outputFormat == "json" {
		return cli.outputPackageInfoJSON(pkg)
	}

	// Output package info in table format
	fmt.Printf("Package Information\n")
	fmt.Printf("==================\n")
	fmt.Printf("Name:         %s\n", pkg.DisplayName)
	fmt.Printf("Internal Name: %s\n", pkg.Name)
	fmt.Printf("Version:      %s\n", pkg.Version)
	fmt.Printf("Kind:         %s\n", pkg.Kind)
	fmt.Printf("Port:         %d\n", pkg.Port)
	fmt.Printf("Base Image:   %s\n", pkg.BaseImage)
	fmt.Printf("Dockerfile:   %s\n", pkg.Dockerfile)
	fmt.Printf("Project:      %s\n", pkg.Project)
	if pkg.Entrypoint != "" {
		fmt.Printf("Entrypoint:   %s\n", pkg.Entrypoint)
	}

	return nil
}

func (cli *CLI) showDependencies(name, version string) error {
	if err := cli.manager.ScanPackages(); err != nil {
		return fmt.Errorf("failed to scan packages: %w", err)
	}

	// Find package
	var pkg *api.PackageInfo
	var err error

	if version != "" {
		pkg, err = cli.manager.GetPackage(name, version)
	} else {
		// Find latest version
		packages := cli.manager.ListPackages("")
		for _, p := range packages {
			if p.Name == name {
				if pkg == nil || p.Version > pkg.Version {
					pkg = p
				}
			}
		}
		if pkg == nil {
			err = fmt.Errorf("package %s not found", name)
		}
	}

	if err != nil {
		return err
	}

	// Get dependencies
	deps, err := cli.manager.GetDependencies(pkg.Name, pkg.Version)
	if err != nil {
		return fmt.Errorf("failed to get dependencies: %w", err)
	}

	if cli.outputFormat == "json" {
		return cli.outputDependenciesJSON(deps)
	}

	// Output dependencies in table format
	fmt.Printf("Dependencies for %s %s\n", pkg.DisplayName, pkg.Version)
	fmt.Printf("========================\n")
	if len(deps.Dependencies) == 0 {
		fmt.Println("No dependencies")
		return nil
	}

	w := tabwriter.NewWriter(os.Stdout, 0, 0, 2, ' ', 0)
	fmt.Fprintln(w, "Name\tVersion\tKind")
	fmt.Fprintln(w, "----\t-------\t----")
	for _, dep := range deps.Dependencies {
		fmt.Fprintf(w, "%s\t%s\t%s\n", dep.Name, dep.Version, dep.Kind)
	}
	w.Flush()

	return nil
}

func (cli *CLI) scanPackages() error {
	if err := cli.manager.ScanPackages(); err != nil {
		return fmt.Errorf("failed to scan packages: %w", err)
	}

	if !cli.quiet {
		fmt.Printf("Scanned %d packages\n", len(cli.manager.Packages))
	}

	return nil
}

func (cli *CLI) generateMeta() error {
	if err := cli.manager.ScanPackages(); err != nil {
		return fmt.Errorf("failed to scan packages: %w", err)
	}

	meta, err := cli.manager.GenerateMeta()
	if err != nil {
		return fmt.Errorf("failed to generate metadata: %w", err)
	}

	// Output metadata
	if cli.outputFormat == "json" {
		return cli.outputMetaJSON(meta)
	}

	// Output summary
	fmt.Printf("Generated metadata for %d packages\n", len(cli.manager.Packages))
	fmt.Printf("Frameworks: %d\n", len(meta.Runtime.Framework))
	fmt.Printf("Languages: %d\n", len(meta.Runtime.Language))
	fmt.Printf("OS: %d\n", len(meta.Runtime.OS))
	fmt.Printf("Custom: %d\n", len(meta.Runtime.Custom))

	return nil
}

func (cli *CLI) validatePackages() error {
	if err := cli.manager.ScanPackages(); err != nil {
		return fmt.Errorf("failed to scan packages: %w", err)
	}

	var errors []string
	for _, pkg := range cli.manager.Packages {
		// Validate required fields
		if pkg.Name == "" {
			errors = append(errors, fmt.Sprintf("Package %s has empty name", pkg.Path))
		}
		if pkg.Version == "" {
			errors = append(errors, fmt.Sprintf("Package %s has empty version", pkg.Path))
		}
		if pkg.Kind == "" {
			errors = append(errors, fmt.Sprintf("Package %s has empty kind", pkg.Path))
		}
		if pkg.Dockerfile == "" {
			errors = append(errors, fmt.Sprintf("Package %s has empty dockerfile", pkg.Path))
		}
	}

	if len(errors) > 0 {
		fmt.Println("Validation errors found:")
		for _, err := range errors {
			fmt.Printf("  - %s\n", err)
		}
		return fmt.Errorf("validation failed with %d errors", len(errors))
	}

	if !cli.quiet {
		fmt.Printf("All %d packages are valid\n", len(cli.manager.Packages))
	}

	return nil
}

func (cli *CLI) searchPackages(query string) error {
	if err := cli.manager.ScanPackages(); err != nil {
		return fmt.Errorf("failed to scan packages: %w", err)
	}

	var results []*api.PackageInfo
	query = strings.ToLower(query)

	for _, pkg := range cli.manager.Packages {
		if strings.Contains(strings.ToLower(pkg.Name), query) ||
			strings.Contains(strings.ToLower(pkg.DisplayName), query) ||
			strings.Contains(strings.ToLower(pkg.Kind), query) {
			results = append(results, pkg)
		}
	}

	if cli.outputFormat == "json" {
		return cli.outputPackagesJSON(results)
	}

	if len(results) == 0 {
		fmt.Printf("No packages found matching '%s'\n", query)
		return nil
	}

	fmt.Printf("Found %d packages matching '%s':\n", len(results), query)
	cli.outputPackagesTable(results)

	return nil
}

func (cli *CLI) outputPackagesJSON(packages []*api.PackageInfo) error {
	data, err := json.MarshalIndent(packages, "", "  ")
	if err != nil {
		return fmt.Errorf("failed to marshal packages: %w", err)
	}
	fmt.Println(string(data))
	return nil
}

func (cli *CLI) outputPackageInfoJSON(pkg *api.PackageInfo) error {
	data, err := json.MarshalIndent(pkg, "", "  ")
	if err != nil {
		return fmt.Errorf("failed to marshal package info: %w", err)
	}
	fmt.Println(string(data))
	return nil
}

func (cli *CLI) outputDependenciesJSON(deps *api.PackageDependencies) error {
	data, err := json.MarshalIndent(deps, "", "  ")
	if err != nil {
		return fmt.Errorf("failed to marshal dependencies: %w", err)
	}
	fmt.Println(string(data))
	return nil
}

func (cli *CLI) outputMetaJSON(meta *api.RuntimeMeta) error {
	data, err := json.MarshalIndent(meta, "", "  ")
	if err != nil {
		return fmt.Errorf("failed to marshal metadata: %w", err)
	}
	fmt.Println(string(data))
	return nil
}

func (cli *CLI) outputPackagesTable(packages []*api.PackageInfo) error {
	if len(packages) == 0 {
		fmt.Println("No packages found")
		return nil
	}

	// Sort packages by name and version
	sort.Slice(packages, func(i, j int) bool {
		if packages[i].Name == packages[j].Name {
			return packages[i].Version > packages[j].Version
		}
		return packages[i].Name < packages[j].Name
	})

	w := tabwriter.NewWriter(os.Stdout, 0, 0, 2, ' ', 0)
	fmt.Fprintln(w, "Name\tVersion\tKind\tPort\tBase Image")
	fmt.Fprintln(w, "----\t-------\t----\t----\t----------")
	for _, pkg := range packages {
		fmt.Fprintf(w, "%s\t%s\t%s\t%d\t%s\n",
			pkg.DisplayName, pkg.Version, pkg.Kind, pkg.Port, pkg.BaseImage)
	}
	w.Flush()

	return nil
}

func (cli *CLI) executeCICommand(subcommand string, args []string) error {
	switch subcommand {
	case "build-matrix":
		return cli.generateBuildMatrix(args)
	case "image-name":
		if len(args) < 4 {
			return fmt.Errorf("image-name command requires <dockerfile> <registry> <namespace> <tag>")
		}
		return cli.generateImageName(args[0], args[1], args[2], args[3])
	case "build":
		if len(args) < 2 {
			return fmt.Errorf("build command requires <dockerfile> <image-name>")
		}
		return cli.buildImage(args)
	case "build-and-push":
		if len(args) < 3 {
			return fmt.Errorf("build-and-push command requires <dockerfile> <image-name1> <image-name2>")
		}
		return cli.buildAndPushImage(args)
	case "generate-config":
		return cli.generateRuntimeConfig(args)
	case "generate-startup":
		return cli.generateStartupScript(args)
	case "validate-build":
		if len(args) < 1 {
			return fmt.Errorf("validate-build command requires <dockerfile>")
		}
		return cli.validateBuild(args[0])
	case "update-base-image":
		if len(args) < 2 {
			return fmt.Errorf("update-base-image command requires <dockerfile> <base-image-name>")
		}
		return cli.updateBaseImage(args[0], args[1])
	case "analyze-dependencies":
		return cli.analyzeDependencies()
	case "build-order":
		return cli.getBuildOrder()
	case "validate-dependencies":
		return cli.validateDependencies()
	case "dependency-graph":
		return cli.generateDependencyGraph()
	default:
		return fmt.Errorf("unknown ci subcommand: %s", subcommand)
	}
}

func (cli *CLI) generateBuildMatrix(args []string) error {
	// Parse flags (for future implementation)
	_ = false // changed
	_ = ""    // commit1
	_ = ""    // commit2
	_ = false // withDependencies

	for i, arg := range args {
		switch arg {
		case "--changed":
			_ = true
		case "--commit1":
			if i+1 < len(args) {
				_ = args[i+1]
			}
		case "--commit2":
			if i+1 < len(args) {
				_ = args[i+1]
			}
		case "--with-dependencies":
			_ = true
		}
	}

	// Scan packages
	if err := cli.manager.ScanPackages(); err != nil {
		return fmt.Errorf("failed to scan packages: %w", err)
	}

	// Get build matrix - for now, return all packages as a simple implementation
	var matrix []string
	for _, pkg := range cli.manager.Packages {
		matrix = append(matrix, pkg.Dockerfile)
	}

	// Output as JSON
	data, err := json.MarshalIndent(matrix, "", "  ")
	if err != nil {
		return fmt.Errorf("failed to marshal build matrix: %w", err)
	}
	fmt.Println(string(data))

	return nil
}

func (cli *CLI) generateImageName(dockerfile, registry, namespace, tag string) error {
	// Extract image name from dockerfile path
	parts := strings.Split(dockerfile, "/")
	if len(parts) < 3 {
		return fmt.Errorf("invalid dockerfile path: %s", dockerfile)
	}

	// Format: runtimes/kind/name/version/Dockerfile
	name := parts[2]
	version := parts[3]

	imageName := fmt.Sprintf("%s-%s", name, version)

	// Generate full image name
	if strings.Contains(registry, "ghcr.io") {
		fullName := fmt.Sprintf("%s/%s/devbox/%s:%s", registry, namespace, imageName, tag)
		fmt.Println(fullName)
	} else {
		// ACR format
		fullName := fmt.Sprintf("%s/%s/%s:%s", registry, namespace, imageName, tag)
		fmt.Println(fullName)
	}

	return nil
}

func (cli *CLI) buildImage(args []string) error {
	dockerfile := args[0]
	imageName := args[1]

	// Parse additional flags
	cn := false
	push := false

	for i, arg := range args[2:] {
		switch arg {
		case "--cn":
			cn = true
		case "--push":
			push = true
		}
		_ = i // avoid unused variable warning
	}

	// Validate dockerfile exists
	if _, err := os.Stat(dockerfile); os.IsNotExist(err) {
		return fmt.Errorf("dockerfile not found: %s", dockerfile)
	}

	// Apply CN modifications if needed
	if cn {
		if err := cli.applyCNModifications(dockerfile); err != nil {
			return fmt.Errorf("failed to apply CN modifications: %w", err)
		}
	}

	// Build command
	buildCmd := fmt.Sprintf("docker buildx build --file %s --platform linux/amd64 --tag %s", dockerfile, imageName)
	if push {
		buildCmd += " --push"
	}
	buildCmd += " ."

	if !cli.quiet {
		fmt.Printf("Building image: %s\n", imageName)
		fmt.Printf("Command: %s\n", buildCmd)
	}

	// In a real implementation, you would execute the build command here
	// For now, just output the command
	fmt.Println(buildCmd)

	return nil
}

func (cli *CLI) applyCNModifications(dockerfile string) error {
	// Read dockerfile
	content, err := os.ReadFile(dockerfile)
	if err != nil {
		return err
	}

	// Backup original file
	backupFile := dockerfile + ".bak"
	if err := os.WriteFile(backupFile, content, 0644); err != nil {
		return fmt.Errorf("failed to create backup: %w", err)
	}

	// Apply CN-specific modifications
	modified := string(content)

	// Common base images
	replacements := map[string]string{
		"FROM ubuntu:24.04": "FROM registry.cn-hangzhou.aliyuncs.com/ubuntu:24.04",
		"FROM ubuntu:22.04": "FROM registry.cn-hangzhou.aliyuncs.com/ubuntu:22.04",
		"FROM ubuntu:20.04": "FROM registry.cn-hangzhou.aliyuncs.com/ubuntu:20.04",
		"FROM debian:12":    "FROM registry.cn-hangzhou.aliyuncs.com/debian:12",
		"FROM debian:11":    "FROM registry.cn-hangzhou.aliyuncs.com/debian:11",
		"FROM alpine:3.18":  "FROM registry.cn-hangzhou.aliyuncs.com/alpine:3.18",
		"FROM alpine:3.19":  "FROM registry.cn-hangzhou.aliyuncs.com/alpine:3.19",
	}

	// Node.js images
	for i := 14; i <= 22; i++ {
		replacements[fmt.Sprintf("FROM node:%d", i)] = fmt.Sprintf("FROM registry.cn-hangzhou.aliyuncs.com/node:%d", i)
	}

	// Python images
	for i := 38; i <= 312; i++ {
		replacements[fmt.Sprintf("FROM python:3.%d", i)] = fmt.Sprintf("FROM registry.cn-hangzhou.aliyuncs.com/python:3.%d", i)
	}

	// Go images
	for i := 118; i <= 122; i++ {
		replacements[fmt.Sprintf("FROM golang:1.%d", i)] = fmt.Sprintf("FROM registry.cn-hangzhou.aliyuncs.com/golang:1.%d", i)
	}

	// Java images
	replacements["FROM openjdk:17"] = "FROM registry.cn-hangzhou.aliyuncs.com/openjdk:17"
	replacements["FROM openjdk:11"] = "FROM registry.cn-hangzhou.aliyuncs.com/openjdk:11"
	replacements["FROM openjdk:8"] = "FROM registry.cn-hangzhou.aliyuncs.com/openjdk:8"

	// Apply all replacements
	for from, to := range replacements {
		modified = strings.ReplaceAll(modified, from, to)
	}

	// Write back
	if err := os.WriteFile(dockerfile, []byte(modified), 0644); err != nil {
		return fmt.Errorf("failed to write modified dockerfile: %w", err)
	}

	if !cli.quiet {
		fmt.Printf("Applied CN modifications to: %s\n", dockerfile)
		fmt.Printf("Backup created at: %s\n", backupFile)
	}

	return nil
}

func (cli *CLI) generateRuntimeConfig(args []string) error {
	// Parse flags
	cn := false
	tag := "latest"

	for i, arg := range args {
		switch arg {
		case "--cn":
			cn = true
		case "--tag":
			if i+1 < len(args) {
				tag = args[i+1]
			}
		}
	}

	_ = tag // TODO: Use tag in future implementation

	// Scan packages
	if err := cli.manager.ScanPackages(); err != nil {
		return fmt.Errorf("failed to scan packages: %w", err)
	}

	// Generate metadata
	meta, err := cli.manager.GenerateMeta()
	if err != nil {
		return fmt.Errorf("failed to generate metadata: %w", err)
	}

	// Output to appropriate file
	outputFile := "config/registry.json"
	if cn {
		outputFile = "config/registry-cn.json"
	}

	data, err := json.MarshalIndent(meta, "", "  ")
	if err != nil {
		return fmt.Errorf("failed to marshal metadata: %w", err)
	}

	if err := os.WriteFile(outputFile, data, 0644); err != nil {
		return fmt.Errorf("failed to write config file: %w", err)
	}

	if !cli.quiet {
		fmt.Printf("Generated runtime config: %s\n", outputFile)
	}

	return nil
}

func (cli *CLI) validateBuild(dockerfile string) error {
	// Check if dockerfile exists
	if _, err := os.Stat(dockerfile); os.IsNotExist(err) {
		return fmt.Errorf("dockerfile not found: %s", dockerfile)
	}

	// Check if dockerfile is in correct location
	if !strings.HasPrefix(dockerfile, "runtimes/") {
		return fmt.Errorf("dockerfile must be in runtimes/ directory: %s", dockerfile)
	}

	// Validate path structure
	parts := strings.Split(dockerfile, "/")
	if len(parts) < 4 {
		return fmt.Errorf("invalid dockerfile path structure: %s", dockerfile)
	}

	// Check for required files
	dir := filepath.Dir(dockerfile)
	projectDir := filepath.Join(dir, "project")
	if _, err := os.Stat(projectDir); os.IsNotExist(err) {
		if !cli.quiet {
			fmt.Printf("Warning: project directory not found: %s\n", projectDir)
		}
	}

	if !cli.quiet {
		fmt.Printf("Build validation passed for: %s\n", dockerfile)
	}

	return nil
}

func (cli *CLI) updateBaseImage(dockerfile, baseImageName string) error {
	// Read dockerfile
	content, err := os.ReadFile(dockerfile)
	if err != nil {
		return fmt.Errorf("failed to read dockerfile: %w", err)
	}

	// Find and replace FROM line
	lines := strings.Split(string(content), "\n")
	modified := false

	for i, line := range lines {
		if strings.HasPrefix(strings.TrimSpace(line), "FROM ") {
			lines[i] = fmt.Sprintf("FROM %s", baseImageName)
			modified = true
			break
		}
	}

	if !modified {
		return fmt.Errorf("no FROM line found in dockerfile")
	}

	// Write back
	modifiedContent := strings.Join(lines, "\n")
	if err := os.WriteFile(dockerfile, []byte(modifiedContent), 0644); err != nil {
		return fmt.Errorf("failed to write modified dockerfile: %w", err)
	}

	if !cli.quiet {
		fmt.Printf("Updated base image in %s to: %s\n", dockerfile, baseImageName)
	}

	return nil
}

func (cli *CLI) analyzeDependencies() error {
	// Scan packages
	if err := cli.manager.ScanPackages(); err != nil {
		return fmt.Errorf("failed to scan packages: %w", err)
	}

	// Analyze dependencies
	analysis, err := cli.manager.AnalyzeDependencies()
	if err != nil {
		return fmt.Errorf("failed to analyze dependencies: %w", err)
	}

	// Output analysis
	if cli.outputFormat == "json" {
		data, err := json.MarshalIndent(analysis, "", "  ")
		if err != nil {
			return fmt.Errorf("failed to marshal analysis: %w", err)
		}
		fmt.Println(string(data))
	} else {
		fmt.Printf("Dependency Analysis\n")
		fmt.Printf("===================\n")
		fmt.Printf("Total packages: %d\n", len(analysis.Nodes))
		fmt.Printf("Dependency analysis completed\n")
	}

	return nil
}

func (cli *CLI) getBuildOrder() error {
	// Scan packages
	if err := cli.manager.ScanPackages(); err != nil {
		return fmt.Errorf("failed to scan packages: %w", err)
	}

	// Get build order
	order, err := cli.manager.GetBuildOrder()
	if err != nil {
		return fmt.Errorf("failed to get build order: %w", err)
	}

	// Output build order
	if cli.outputFormat == "json" {
		data, err := json.MarshalIndent(order, "", "  ")
		if err != nil {
			return fmt.Errorf("failed to marshal build order: %w", err)
		}
		fmt.Println(string(data))
	} else {
		fmt.Printf("Build Order\n")
		fmt.Printf("===========\n")
		for i, target := range order {
			fmt.Printf("%d. %s\n", i+1, target)
		}
	}

	return nil
}

func (cli *CLI) validateDependencies() error {
	// Scan packages
	if err := cli.manager.ScanPackages(); err != nil {
		return fmt.Errorf("failed to scan packages: %w", err)
	}

	// Validate dependencies
	err := cli.manager.ValidateDependencies()
	if err != nil {
		return fmt.Errorf("dependency validation failed: %w", err)
	}

	if !cli.quiet {
		fmt.Println("All dependencies are valid")
	}

	return nil
}

func (cli *CLI) generateDependencyGraph() error {
	// Scan packages
	if err := cli.manager.ScanPackages(); err != nil {
		return fmt.Errorf("failed to scan packages: %w", err)
	}

	// Get dependency graph
	graph, err := cli.manager.AnalyzeDependencies()
	if err != nil {
		return fmt.Errorf("failed to get dependency graph: %w", err)
	}

	// Output Mermaid diagram
	fmt.Println("```mermaid")
	fmt.Println("graph TD")

	// Add nodes
	for _, node := range graph.Nodes {
		nodeId := strings.ReplaceAll(node.Name, "-", "_")
		nodeLabel := fmt.Sprintf("%s (%s)", node.Name, node.Version)

		// Add node
		fmt.Printf("    %s[\"%s\"]\n", nodeId, nodeLabel)

		// Add dependencies
		for _, dep := range node.Dependencies {
			depId := strings.ReplaceAll(dep, "-", "_")
			fmt.Printf("    %s --> %s\n", depId, nodeId)
		}
	}

	fmt.Println("```")
	return nil
}

// buildAndPushImage builds and pushes a Docker image with multiple tags
func (cli *CLI) buildAndPushImage(args []string) error {
	dockerfile := args[0]
	imageName1 := args[1]
	imageName2 := args[2]

	// Parse additional flags
	cn := false
	for i, arg := range args[3:] {
		switch arg {
		case "--cn":
			cn = true
		}
		_ = i // avoid unused variable warning
	}

	// Validate dockerfile exists
	if _, err := os.Stat(dockerfile); os.IsNotExist(err) {
		return fmt.Errorf("dockerfile not found: %s", dockerfile)
	}

	// Apply CN modifications if needed
	if cn {
		if err := cli.applyCNModifications(dockerfile); err != nil {
			return fmt.Errorf("failed to apply CN modifications: %w", err)
		}
	}

	// Build and push command with multiple tags
	buildCmd := fmt.Sprintf("docker buildx build --push --file %s --platform linux/amd64 --tag %s --tag %s .",
		dockerfile, imageName1, imageName2)

	if !cli.quiet {
		fmt.Printf("Building and pushing image with tags: %s, %s\n", imageName1, imageName2)
		fmt.Printf("Command: %s\n", buildCmd)
	}

	// In a real implementation, you would execute the build command here
	// For now, just output the command
	fmt.Println(buildCmd)

	return nil
}

// generateStartupScript generates a startup script for containers
func (cli *CLI) generateStartupScript(args []string) error {
	outputPath := "/usr/start/startup.sh"

	// Parse flags
	for i, arg := range args {
		switch arg {
		case "--output":
			if i+1 < len(args) {
				outputPath = args[i+1]
			}
		}
	}

	startupScript := `#!/bin/bash

# Set hostname if SEALOS_DEVBOX_NAME is provided
if [ ! -z "${SEALOS_DEVBOX_NAME}" ]; then
    echo "${SEALOS_DEVBOX_NAME}" > /etc/hostname
fi

# Store pod UID
echo "${SEALOS_DEVBOX_POD_UID}" > /usr/start/pod_id

# Start the SSH daemon
/usr/sbin/sshd

# Keep container running
sleep infinity
`

	// Create output directory if it doesn't exist
	outputDir := filepath.Dir(outputPath)
	if err := os.MkdirAll(outputDir, 0755); err != nil {
		return fmt.Errorf("failed to create output directory: %w", err)
	}

	// Write startup script
	if err := os.WriteFile(outputPath, []byte(startupScript), 0755); err != nil {
		return fmt.Errorf("failed to write startup script: %w", err)
	}

	if !cli.quiet {
		fmt.Printf("Generated startup script: %s\n", outputPath)
	}

	return nil
}
