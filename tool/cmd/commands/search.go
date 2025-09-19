package commands

import (
	"fmt"
	"strings"

	"github.com/labring-actions/devbox-runtime/tool/api"
	"github.com/spf13/cobra"
)

func NewSearchCommand(registryPath, outputFormat *string, quiet *bool) *cobra.Command {
	cmd := &cobra.Command{
		Use:   "search <query>",
		Short: "Search for packages by name or description",
		Long:  "Search for packages by name, display name, or kind",
		Args:  cobra.MinimumNArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			manager := api.NewRuntimeManager(*registryPath)

			if err := manager.ScanPackages(); err != nil {
				return fmt.Errorf("failed to scan packages: %w", err)
			}

			query := strings.ToLower(args[0])
			var results []*api.PackageInfo

			for _, pkg := range manager.Packages {
				if strings.Contains(strings.ToLower(pkg.Name), query) ||
					strings.Contains(strings.ToLower(pkg.DisplayName), query) ||
					strings.Contains(strings.ToLower(pkg.Kind), query) {
					results = append(results, pkg)
				}
			}

			if *outputFormat == "json" {
				return outputPackagesJSON(results)
			}

			if len(results) == 0 {
				fmt.Printf("No packages found matching '%s'\n", query)
				return nil
			}

			fmt.Printf("Found %d packages matching '%s':\n", len(results), query)
			outputPackagesTable(results)

			return nil
		},
	}

	return cmd
}
