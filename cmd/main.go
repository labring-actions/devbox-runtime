package main

import (
	"flag"
	"fmt"
	"log"
	"os"

	"github.com/labring-actions/devbox-runtime/api"
)

const (
	Version = "1.0.0"
	Usage   = `DevBox Runtime Manager - Manage runtime packages and their dependencies

Usage:
  runtimectl [command] [options]

Commands:
  list                    List all available runtime packages
  list-frameworks         List all framework packages
  list-languages          List all language packages
  list-os                 List all OS packages
  list-services           List all service packages
  info <name> [version]   Show detailed information about a package
  dependencies <name> [version] Show dependencies for a package
  scan                    Scan filesystem for packages and update metadata
  generate-meta           Generate runtime metadata from scanned packages
  validate                Validate package configurations
  search <query>          Search for packages by name or description

CI/CD Commands:
  ci build-matrix [--changed] [--commit1 <hash>] [--commit2 <hash>] [--with-dependencies]  Generate build matrix for CI
  ci image-name <dockerfile> <registry> <namespace> <tag>            Generate image name for build
  ci build <dockerfile> <image-name> [--cn] [--push]                 Build and optionally push image
  ci build-and-push <dockerfile> <image-name1> <image-name2> [--cn] Build and push image with multiple tags
  ci generate-config [--cn] [--tag <tag>]                            Generate runtime configuration
  ci generate-startup [--output <path>]                              Generate startup script for containers
  ci validate-build <dockerfile>                                     Validate build configuration
  ci update-base-image <dockerfile> <base-image-name>               Update base image in Dockerfile
  ci analyze-dependencies                                           Analyze package dependencies
  ci build-order                                                    Get build order based on dependencies
  ci validate-dependencies                                          Validate all dependencies
  ci dependency-graph                                               Generate dependency graph visualization

Options:
  -h, --help              Show this help message
  -v, --version           Show version information
  -d, --dir <path>        Specify registry directory (default: current directory)
  -o, --output <format>   Output format: json, table (default: table)
  -q, --quiet             Quiet mode, minimal output

Examples:
  runtimectl list
  runtimectl list-frameworks
  runtimectl info vue v3.4.29
  runtimectl dependencies python 3.12
  runtimectl scan
  runtimectl search react
`
)

type CLI struct {
	registryPath string
	outputFormat string
	quiet        bool
	manager      *api.RuntimeManager
}

func main() {
	cli := &CLI{}

	// Parse flags
	flag.StringVar(&cli.registryPath, "d", ".", "Registry directory path")
	flag.StringVar(&cli.outputFormat, "o", "table", "Output format (json, table)")
	flag.BoolVar(&cli.quiet, "q", false, "Quiet mode")
	flag.Usage = func() {
		fmt.Fprintf(os.Stderr, Usage)
	}
	flag.Parse()

	// Initialize runtime manager
	cli.manager = api.NewRuntimeManager(cli.registryPath)

	// Get command
	args := flag.Args()
	if len(args) == 0 {
		fmt.Fprintf(os.Stderr, "Error: No command specified\n\n")
		fmt.Fprintf(os.Stderr, Usage)
		os.Exit(1)
	}

	command := args[0]
	commandArgs := args[1:]

	// Execute command
	if err := cli.executeCommand(command, commandArgs); err != nil {
		if !cli.quiet {
			log.Fatalf("Error: %v", err)
		}
		os.Exit(1)
	}
}

func (cli *CLI) executeCommand(command string, args []string) error {
	switch command {
	case "list":
		return cli.listAllPackages()
	case "list-frameworks":
		return cli.listPackages("framework")
	case "list-languages":
		return cli.listPackages("language")
	case "list-os":
		return cli.listPackages("os")
	case "list-services":
		return cli.listPackages("service")
	case "info":
		if len(args) < 1 {
			return fmt.Errorf("info command requires package name")
		}
		version := ""
		if len(args) > 1 {
			version = args[1]
		}
		return cli.showPackageInfo(args[0], version)
	case "dependencies":
		if len(args) < 1 {
			return fmt.Errorf("dependencies command requires package name")
		}
		version := ""
		if len(args) > 1 {
			version = args[1]
		}
		return cli.showDependencies(args[0], version)
	case "scan":
		return cli.scanPackages()
	case "generate-meta":
		return cli.generateMeta()
	case "validate":
		return cli.validatePackages()
	case "search":
		if len(args) < 1 {
			return fmt.Errorf("search command requires query")
		}
		return cli.searchPackages(args[0])
	case "ci":
		if len(args) < 1 {
			return fmt.Errorf("ci command requires subcommand")
		}
		return cli.executeCICommand(args[0], args[1:])
	default:
		return fmt.Errorf("unknown command: %s", command)
	}
}
