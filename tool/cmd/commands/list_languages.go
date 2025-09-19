package commands

import (
	"fmt"

	"github.com/labring-actions/devbox-runtime/tool/api"
	"github.com/spf13/cobra"
)

func NewListLanguagesCommand(registryPath, outputFormat *string, quiet *bool) *cobra.Command {
	cmd := &cobra.Command{
		Use:   "list-languages",
		Short: "List all language packages",
		Long:  "List all available language packages",
		RunE: func(cmd *cobra.Command, args []string) error {
			manager := api.NewRuntimeManager(*registryPath)

			if err := manager.ScanPackages(); err != nil {
				return fmt.Errorf("failed to scan packages: %w", err)
			}

			packages := manager.ListPackages("language")

			if *outputFormat == "json" {
				return outputPackagesJSON(packages)
			}

			fmt.Printf("=== Language Packages ===\n")
			outputPackagesTable(packages)
			return nil
		},
	}

	return cmd
}
