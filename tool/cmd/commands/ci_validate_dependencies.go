package commands

import (
	"fmt"

	"github.com/labring-actions/devbox-runtime/tool/api"
	"github.com/spf13/cobra"
)

func NewValidateDependenciesCommand(registryPath, outputFormat *string, quiet *bool) *cobra.Command {
	cmd := &cobra.Command{
		Use:   "validate-dependencies",
		Short: "Validate all dependencies",
		Long:  "Validate that all package dependencies are available and correctly configured",
		RunE: func(cmd *cobra.Command, args []string) error {
			manager := api.NewRuntimeManager(*registryPath)

			if err := manager.ScanPackages(); err != nil {
				return fmt.Errorf("failed to scan packages: %w", err)
			}

			// Validate dependencies
			err := manager.ValidateDependencies()
			if err != nil {
				return fmt.Errorf("dependency validation failed: %w", err)
			}

			if !*quiet {
				fmt.Println("All dependencies are valid")
			}

			return nil
		},
	}

	return cmd
}
