package commands

import (
	"fmt"

	"github.com/labring-actions/devbox-runtime/tool/api"
	"github.com/spf13/cobra"
)

func NewScanCommand(registryPath, outputFormat *string, quiet *bool) *cobra.Command {
	cmd := &cobra.Command{
		Use:   "scan",
		Short: "Scan filesystem for packages and update metadata",
		Long:  "Scan the filesystem for runtime packages and update metadata",
		RunE: func(cmd *cobra.Command, args []string) error {
			manager := api.NewRuntimeManager(*registryPath)

			if err := manager.ScanPackages(); err != nil {
				return fmt.Errorf("failed to scan packages: %w", err)
			}

			if !*quiet {
				fmt.Printf("Scanned %d packages\n", len(manager.Packages))
			}

			return nil
		},
	}

	return cmd
}
