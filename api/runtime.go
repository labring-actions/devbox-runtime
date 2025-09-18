package api

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"time"
)

// Meta represents package metadata
type Meta struct {
	MetaVersion  string            `json:"metaVersion"`
	Name         string            `json:"name"`
	Dependencies map[string]string `json:"dependencies"`
}

// RuntimeState represents the state of a runtime version
type RuntimeState string

const (
	StateActive     RuntimeState = "active"
	StateDeprecated RuntimeState = "deprecated"
	StateTesting    RuntimeState = "testing"
)

// PortConfig represents port configuration
type PortConfig struct {
	Name     string `json:"name"`
	Port     int    `json:"port"`
	Protocol string `json:"protocol"`
}

// RuntimeConfig represents runtime configuration
type RuntimeConfig struct {
	AppPorts       []PortConfig `json:"appPorts"`
	Ports          []PortConfig `json:"ports"`
	ReleaseArgs    []string     `json:"releaseArgs"`
	ReleaseCommand []string     `json:"releaseCommand"`
	User           string       `json:"user"`
	WorkingDir     string       `json:"workingDir"`
}

// RuntimeVersion represents a specific version of a runtime
type RuntimeVersion struct {
	Name    string       `json:"name"`
	Image   string       `json:"image"`
	Config  string       `json:"config"`
	State   RuntimeState `json:"state"`
	Created time.Time    `json:"created,omitempty"`
	Updated time.Time    `json:"updated,omitempty"`
}

// RuntimePackage represents a runtime package (Framework, Language, OS, etc.)
type RuntimePackage struct {
	Name     string           `json:"name"`
	Kind     string           `json:"kind"`
	Versions []RuntimeVersion `json:"version"`
}

// RuntimeRegistry represents the complete runtime registry
type RuntimeRegistry struct {
	Framework []RuntimePackage `json:"Framework"`
	Language  []RuntimePackage `json:"Language"`
	OS        []RuntimePackage `json:"OS"`
	Custom    []RuntimePackage `json:"Custom"`
}

// RuntimeMeta represents the complete runtime metadata
type RuntimeMeta struct {
	Runtime RuntimeRegistry `json:"runtime"`
}

// PackageInfo represents package information from filesystem
type PackageInfo struct {
	Path        string
	Name        string
	Kind        string
	Version     string
	Dockerfile  string
	Project     string
	Entrypoint  string
	Config      *RuntimeConfig
	Port        int
	DisplayName string
	BaseImage   string
}

// Dependency represents a package dependency
type Dependency struct {
	Name    string `json:"name"`
	Version string `json:"version"`
	Kind    string `json:"kind"`
}

// PackageDependencies represents dependencies for a package
type PackageDependencies struct {
	Package      string       `json:"package"`
	Version      string       `json:"version"`
	Dependencies []Dependency `json:"dependencies"`
	BaseImage    string       `json:"base_image,omitempty"`
}

// RuntimeManager manages runtime packages and their dependencies
type RuntimeManager struct {
	RegistryPath string
	Meta         *RuntimeMeta
	Packages     map[string]*PackageInfo
	Dependencies map[string]*PackageDependencies
}

// NewRuntimeManager creates a new runtime manager
func NewRuntimeManager(registryPath string) *RuntimeManager {
	return &RuntimeManager{
		RegistryPath: registryPath,
		Packages:     make(map[string]*PackageInfo),
		Dependencies: make(map[string]*PackageDependencies),
	}
}

// LoadMeta loads runtime metadata from JSON files
func (rm *RuntimeManager) LoadMeta() error {
	// Try to load from config/registry.json first, then config/registry-cn.json
	configFiles := []string{"config/registry.json", "config/registry-cn.json"}

	for _, configFile := range configFiles {
		configPath := filepath.Join(rm.RegistryPath, configFile)
		if _, err := os.Stat(configPath); err == nil {
			data, err := os.ReadFile(configPath)
			if err != nil {
				continue
			}

			var meta RuntimeMeta
			if err := json.Unmarshal(data, &meta); err != nil {
				continue
			}

			rm.Meta = &meta
			return nil
		}
	}

	return fmt.Errorf("no valid config file found")
}

// ScanPackages scans the filesystem for runtime packages
func (rm *RuntimeManager) ScanPackages() error {
	// Scan Framework packages
	if err := rm.scanPackageDirectory("runtimes/frameworks", "framework"); err != nil {
		return fmt.Errorf("failed to scan frameworks: %w", err)
	}

	// Scan Language packages
	if err := rm.scanPackageDirectory("runtimes/languages", "language"); err != nil {
		return fmt.Errorf("failed to scan languages: %w", err)
	}

	// Scan OS packages
	if err := rm.scanPackageDirectory("runtimes/operating-systems", "os"); err != nil {
		return fmt.Errorf("failed to scan operating-systems: %w", err)
	}

	// Scan Service packages
	if err := rm.scanPackageDirectory("runtimes/services", "service"); err != nil {
		return fmt.Errorf("failed to scan services: %w", err)
	}

	return nil
}

// scanPackageDirectory scans a specific package directory
func (rm *RuntimeManager) scanPackageDirectory(dirName, kind string) error {
	dirPath := filepath.Join(rm.RegistryPath, dirName)
	if _, err := os.Stat(dirPath); os.IsNotExist(err) {
		return nil // Directory doesn't exist, skip
	}

	return filepath.Walk(dirPath, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}

		// Look for Dockerfile
		if info.Name() == "Dockerfile" {
			packageInfo, err := rm.parsePackageFromDockerfile(path, kind)
			if err != nil {
				return err
			}

			if packageInfo != nil {
				key := fmt.Sprintf("%s-%s-%s", packageInfo.Kind, packageInfo.Name, packageInfo.Version)
				rm.Packages[key] = packageInfo
			}
		}

		return nil
	})
}

// parsePackageFromDockerfile parses package information from Dockerfile
func (rm *RuntimeManager) parsePackageFromDockerfile(dockerfilePath, kind string) (*PackageInfo, error) {
	// Extract package name and version from path
	// e.g., Framework/vue/v3.4.29/Dockerfile -> vue, v3.4.29
	relPath, err := filepath.Rel(rm.RegistryPath, dockerfilePath)
	if err != nil {
		return nil, err
	}

	parts := strings.Split(relPath, string(filepath.Separator))
	if len(parts) < 4 {
		return nil, fmt.Errorf("invalid package path: %s", relPath)
	}

	packageName := parts[2] // e.g., "vue" from "runtimes/frameworks/vue/v3.4.29/Dockerfile"
	version := parts[3]     // e.g., "v3.4.29"

	// Read Dockerfile to extract base image and dependencies
	dockerfileContent, err := os.ReadFile(dockerfilePath)
	if err != nil {
		return nil, err
	}

	packageInfo := &PackageInfo{
		Path:       filepath.Dir(dockerfilePath),
		Name:       packageName,
		Kind:       kind,
		Version:    version,
		Dockerfile: dockerfilePath,
		Port:       rm.getDefaultPort(packageName),
	}

	// Parse base image from FROM instruction
	lines := strings.Split(string(dockerfileContent), "\n")
	for _, line := range lines {
		line = strings.TrimSpace(line)
		if strings.HasPrefix(line, "FROM ") {
			baseImage := strings.TrimPrefix(line, "FROM ")
			packageInfo.BaseImage = baseImage
			packageInfo.Config = &RuntimeConfig{
				User:       "devbox",
				WorkingDir: "/home/devbox/project",
			}
			// Store base image for dependency tracking
			rm.Dependencies[fmt.Sprintf("%s-%s", packageName, version)] = &PackageDependencies{
				Package:   packageName,
				Version:   version,
				BaseImage: baseImage,
			}
			break
		}
	}

	// Check for project directory
	projectPath := filepath.Join(packageInfo.Path, "project")
	if _, err := os.Stat(projectPath); err == nil {
		packageInfo.Project = projectPath

		// Check for entrypoint script
		entrypointPath := filepath.Join(projectPath, "entrypoint.sh")
		if _, err := os.Stat(entrypointPath); err == nil {
			packageInfo.Entrypoint = entrypointPath
		}
	}

	// Get display name from configs/name.txt
	packageInfo.DisplayName = rm.getDisplayName(packageName)

	return packageInfo, nil
}

// getDefaultPort gets the default port for a package
func (rm *RuntimeManager) getDefaultPort(packageName string) int {
	// Try to load from registry.json first
	if rm.Meta != nil && rm.Meta.Runtime.Framework != nil {
		// Check if we have port mappings in the registry
		// This would need to be implemented based on the new structure
	}

	// Fallback to default port
	return 8080
}

// getDisplayName gets the display name for a package
func (rm *RuntimeManager) getDisplayName(packageName string) string {
	// Try to load from registry.json first
	if rm.Meta != nil && rm.Meta.Runtime.Framework != nil {
		// Check if we have name mappings in the registry
		// This would need to be implemented based on the new structure
	}

	// Fallback to package name
	return packageName
}

// GetPackage returns package information by name and version
func (rm *RuntimeManager) GetPackage(name, version string) (*PackageInfo, error) {
	key := fmt.Sprintf("%s-%s", name, version)
	for k, pkg := range rm.Packages {
		if strings.Contains(k, key) {
			return pkg, nil
		}
	}
	return nil, fmt.Errorf("package %s:%s not found", name, version)
}

// ListPackages returns all packages of a specific kind
func (rm *RuntimeManager) ListPackages(kind string) []*PackageInfo {
	var packages []*PackageInfo
	for _, pkg := range rm.Packages {
		if pkg.Kind == kind {
			packages = append(packages, pkg)
		}
	}
	return packages
}

// GetDependencies returns dependencies for a package
func (rm *RuntimeManager) GetDependencies(name, version string) (*PackageDependencies, error) {
	key := fmt.Sprintf("%s-%s", name, version)
	if deps, exists := rm.Dependencies[key]; exists {
		return deps, nil
	}
	return nil, fmt.Errorf("dependencies for %s:%s not found", name, version)
}

// GenerateMeta generates runtime metadata from scanned packages
func (rm *RuntimeManager) GenerateMeta() (*RuntimeMeta, error) {
	meta := &RuntimeMeta{
		Runtime: RuntimeRegistry{
			Framework: []RuntimePackage{},
			Language:  []RuntimePackage{},
			OS:        []RuntimePackage{},
			Custom:    []RuntimePackage{},
		},
	}

	// Group packages by kind and name
	packageGroups := make(map[string]map[string][]*PackageInfo)

	for _, pkg := range rm.Packages {
		if packageGroups[pkg.Kind] == nil {
			packageGroups[pkg.Kind] = make(map[string][]*PackageInfo)
		}
		packageGroups[pkg.Kind][pkg.Name] = append(packageGroups[pkg.Kind][pkg.Name], pkg)
	}

	// Convert to RuntimePackage format
	for kind, packages := range packageGroups {
		var runtimePackages []RuntimePackage

		for _, versions := range packages {
			var runtimeVersions []RuntimeVersion

			for _, pkg := range versions {
				configJSON, _ := json.Marshal(pkg.Config)
				version := RuntimeVersion{
					Name:   pkg.Version,
					Image:  fmt.Sprintf("ghcr.io/labring-actions/devbox/%s-%s:latest", pkg.Name, pkg.Version),
					Config: string(configJSON),
					State:  StateActive,
				}
				runtimeVersions = append(runtimeVersions, version)
			}

			runtimePackage := RuntimePackage{
				Name:     versions[0].DisplayName,
				Kind:     kind,
				Versions: runtimeVersions,
			}
			runtimePackages = append(runtimePackages, runtimePackage)
		}

		// Assign to appropriate registry section
		switch kind {
		case "framework":
			meta.Runtime.Framework = runtimePackages
		case "language":
			meta.Runtime.Language = runtimePackages
		case "os":
			meta.Runtime.OS = runtimePackages
		case "service":
			meta.Runtime.Custom = runtimePackages
		}
	}

	return meta, nil
}

// DependencyNode represents a node in the dependency graph
type DependencyNode struct {
	Path         string   `json:"path"`
	Name         string   `json:"name"`
	Kind         string   `json:"kind"`
	Version      string   `json:"version"`
	BaseImage    string   `json:"base_image"`
	Dependencies []string `json:"dependencies"`
	Level        int      `json:"level"` // 0=base, 1=language, 2=framework
}

// DependencyGraph represents the complete dependency graph
type DependencyGraph struct {
	Nodes  []DependencyNode `json:"nodes"`
	Levels [][]string       `json:"levels"` // Grouped by dependency level
}

// AnalyzeDependencies analyzes dependencies for all packages
func (rm *RuntimeManager) AnalyzeDependencies() (*DependencyGraph, error) {
	graph := &DependencyGraph{
		Nodes:  []DependencyNode{},
		Levels: make([][]string, 3), // 3 levels: base, language, framework
	}

	// First pass: create all nodes
	for _, pkg := range rm.Packages {
		node := DependencyNode{
			Path:         pkg.Dockerfile,
			Name:         pkg.Name,
			Kind:         pkg.Kind,
			Version:      pkg.Version,
			BaseImage:    pkg.BaseImage,
			Dependencies: []string{},
		}

		// Determine dependency level
		switch pkg.Kind {
		case "os":
			node.Level = 0 // Base level
		case "language":
			node.Level = 1 // Language level
		case "framework", "service":
			node.Level = 2 // Framework level
		}

		graph.Nodes = append(graph.Nodes, node)
	}

	// Second pass: analyze dependencies
	for i, node := range graph.Nodes {
		deps := rm.extractDependencies(node.BaseImage)
		graph.Nodes[i].Dependencies = deps
		graph.Levels[node.Level] = append(graph.Levels[node.Level], node.Path)
	}

	return graph, nil
}

// extractDependencies extracts dependencies from a base image reference
func (rm *RuntimeManager) extractDependencies(baseImage string) []string {
	var dependencies []string

	// Check if it's a devbox image (has our namespace)
	if strings.Contains(baseImage, "ghcr.io/labring-actions/devbox/") {
		// Extract package name from image
		parts := strings.Split(baseImage, "/")
		if len(parts) > 0 {
			imageName := parts[len(parts)-1]
			// Remove tag if present
			if colonIndex := strings.LastIndex(imageName, ":"); colonIndex != -1 {
				imageName = imageName[:colonIndex]
			}
			dependencies = append(dependencies, imageName)
		}
	}

	return dependencies
}

// GetBuildOrder returns the build order based on dependencies
func (rm *RuntimeManager) GetBuildOrder() ([]string, error) {
	graph, err := rm.AnalyzeDependencies()
	if err != nil {
		return nil, err
	}

	var buildOrder []string

	// Build in level order: base -> language -> framework
	for level := 0; level < 3; level++ {
		buildOrder = append(buildOrder, graph.Levels[level]...)
	}

	return buildOrder, nil
}

// GetDependenciesForPath returns dependencies for a specific dockerfile path
func (rm *RuntimeManager) GetDependenciesForPath(dockerfilePath string) ([]string, error) {
	graph, err := rm.AnalyzeDependencies()
	if err != nil {
		return nil, err
	}

	for _, node := range graph.Nodes {
		if node.Path == dockerfilePath {
			return node.Dependencies, nil
		}
	}

	return []string{}, nil
}

// ValidateDependencies validates that all dependencies are available
func (rm *RuntimeManager) ValidateDependencies() error {
	graph, err := rm.AnalyzeDependencies()
	if err != nil {
		return err
	}

	for _, node := range graph.Nodes {
		for _, dep := range node.Dependencies {
			// Check if dependency exists in our packages
			found := false
			for _, pkg := range rm.Packages {
				expectedImageName := fmt.Sprintf("%s-%s", pkg.Name, pkg.Version)
				if expectedImageName == dep {
					found = true
					break
				}
			}
			if !found {
				return fmt.Errorf("dependency %s not found for %s", dep, node.Path)
			}
		}
	}

	return nil
}
