package commands

import (
	"fmt"

	"github.com/labring-actions/devbox-runtime/tool/api"
	"github.com/spf13/cobra"
)

func NewListFrameworksCommand(registryPath, outputFormat *string, quiet *bool) *cobra.Command {
	cmd := &cobra.Command{
		Use:   "list-frameworks",
		Short: "List all framework packages",
		Long:  "List all available framework packages",
		RunE: func(cmd *cobra.Command, args []string) error {
			manager := api.NewRuntimeManager(*registryPath)

			if err := manager.ScanPackages(); err != nil {
				return fmt.Errorf("failed to scan packages: %w", err)
			}

			packages := manager.ListPackages("framework")

			if *outputFormat == "json" {
				return outputPackagesJSON(packages)
			}

			fmt.Printf("=== Framework Packages ===\n")
			outputPackagesTable(packages)
			return nil
		},
	}

	return cmd
}
