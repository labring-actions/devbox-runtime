package commands

import (
	"fmt"

	"github.com/labring-actions/devbox-runtime/tool/api"
	"github.com/spf13/cobra"
)

func NewValidateCommand(registryPath, outputFormat *string, quiet *bool) *cobra.Command {
	cmd := &cobra.Command{
		Use:   "validate",
		Short: "Validate package configurations",
		Long:  "Validate all package configurations for required fields and consistency",
		RunE: func(cmd *cobra.Command, args []string) error {
			manager := api.NewRuntimeManager(*registryPath)

			if err := manager.ScanPackages(); err != nil {
				return fmt.Errorf("failed to scan packages: %w", err)
			}

			var errors []string
			for _, pkg := range manager.Packages {
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

			if !*quiet {
				fmt.Printf("All %d packages are valid\n", len(manager.Packages))
			}

			return nil
		},
	}

	return cmd
}
