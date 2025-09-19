package main

import (
	"fmt"
	"os"

	"github.com/labring-actions/devbox-runtime/tool/cmd/commands"
	"github.com/spf13/cobra"
)

const (
	Version = "1.0.0"
)

var (
	registryPath string
	outputFormat string
	quiet        bool
)

func main() {
	var rootCmd = &cobra.Command{
		Use:   "runtimectl",
		Short: "DevBox Runtime Manager - Manage runtime packages and their dependencies",
		Long: `DevBox Runtime Manager - Manage runtime packages and their dependencies

This tool helps manage runtime packages and their dependencies for DevBox.
It provides commands to list, analyze, and build runtime packages.`,
		Version: Version,
	}

	// Global flags
	rootCmd.PersistentFlags().StringVarP(&registryPath, "dir", "d", ".", "Registry directory path")
	rootCmd.PersistentFlags().StringVarP(&outputFormat, "output", "o", "table", "Output format (json, table)")
	rootCmd.PersistentFlags().BoolVarP(&quiet, "quiet", "q", false, "Quiet mode, minimal output")

	// Add subcommands
	rootCmd.AddCommand(commands.NewListCommand(&registryPath, &outputFormat, &quiet))
	rootCmd.AddCommand(commands.NewListFrameworksCommand(&registryPath, &outputFormat, &quiet))
	rootCmd.AddCommand(commands.NewListLanguagesCommand(&registryPath, &outputFormat, &quiet))
	rootCmd.AddCommand(commands.NewListOSCommand(&registryPath, &outputFormat, &quiet))
	rootCmd.AddCommand(commands.NewListServicesCommand(&registryPath, &outputFormat, &quiet))
	rootCmd.AddCommand(commands.NewInfoCommand(&registryPath, &outputFormat, &quiet))
	rootCmd.AddCommand(commands.NewDependenciesCommand(&registryPath, &outputFormat, &quiet))
	rootCmd.AddCommand(commands.NewScanCommand(&registryPath, &outputFormat, &quiet))
	rootCmd.AddCommand(commands.NewGenerateMetaCommand(&registryPath, &outputFormat, &quiet))
	rootCmd.AddCommand(commands.NewValidateCommand(&registryPath, &outputFormat, &quiet))
	rootCmd.AddCommand(commands.NewSearchCommand(&registryPath, &outputFormat, &quiet))
	rootCmd.AddCommand(commands.NewCICommand(&registryPath, &outputFormat, &quiet))

	if err := rootCmd.Execute(); err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
}
