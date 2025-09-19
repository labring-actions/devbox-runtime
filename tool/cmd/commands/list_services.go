package commands

import (
	"fmt"

	"github.com/labring-actions/devbox-runtime/tool/api"
	"github.com/spf13/cobra"
)

func NewListServicesCommand(registryPath, outputFormat *string, quiet *bool) *cobra.Command {
	cmd := &cobra.Command{
		Use:   "list-services",
		Short: "List all service packages",
		Long:  "List all available service packages",
		RunE: func(cmd *cobra.Command, args []string) error {
			manager := api.NewRuntimeManager(*registryPath)

			if err := manager.ScanPackages(); err != nil {
				return fmt.Errorf("failed to scan packages: %w", err)
			}

			packages := manager.ListPackages("service")

			if *outputFormat == "json" {
				return outputPackagesJSON(packages)
			}

			fmt.Printf("=== Service Packages ===\n")
			outputPackagesTable(packages)
			return nil
		},
	}

	return cmd
}
