package commands

import (
	"fmt"
	"strings"

	"github.com/labring-actions/devbox-runtime/tool/api"
	"github.com/spf13/cobra"
)

func NewListCommand(registryPath, outputFormat *string, quiet *bool) *cobra.Command {
	cmd := &cobra.Command{
		Use:   "list",
		Short: "List all available runtime packages",
		Long:  "List all available runtime packages grouped by kind (framework, language, os, service)",
		RunE: func(cmd *cobra.Command, args []string) error {
			manager := api.NewRuntimeManager(*registryPath)

			if err := manager.ScanPackages(); err != nil {
				return fmt.Errorf("failed to scan packages: %w", err)
			}

			if *outputFormat == "json" {
				// Convert map to slice for JSON output
				var packages []*api.PackageInfo
				for _, pkg := range manager.Packages {
					packages = append(packages, pkg)
				}
				return outputPackagesJSON(packages)
			}

			// Group packages by kind
			kinds := []string{"framework", "language", "os", "service"}
			for _, kind := range kinds {
				packages := manager.ListPackages(kind)
				if len(packages) > 0 {
					fmt.Printf("\n=== %s Packages ===\n", strings.Title(kind))
					outputPackagesTable(packages)
				}
			}

			return nil
		},
	}

	return cmd
}
