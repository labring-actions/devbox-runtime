package commands

import (
	"fmt"

	"github.com/labring-actions/devbox-runtime/tool/api"
	"github.com/spf13/cobra"
)

func NewListOSCommand(registryPath, outputFormat *string, quiet *bool) *cobra.Command {
	cmd := &cobra.Command{
		Use:   "list-os",
		Short: "List all OS packages",
		Long:  "List all available operating system packages",
		RunE: func(cmd *cobra.Command, args []string) error {
			manager := api.NewRuntimeManager(*registryPath)

			if err := manager.ScanPackages(); err != nil {
				return fmt.Errorf("failed to scan packages: %w", err)
			}

			packages := manager.ListPackages("os")

			if *outputFormat == "json" {
				return outputPackagesJSON(packages)
			}

			fmt.Printf("=== OS Packages ===\n")
			outputPackagesTable(packages)
			return nil
		},
	}

	return cmd
}
