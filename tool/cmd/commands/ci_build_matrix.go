package commands

import (
	"encoding/json"
	"fmt"

	"github.com/labring-actions/devbox-runtime/tool/api"
	"github.com/spf13/cobra"
)

func NewBuildMatrixCommand(registryPath, outputFormat *string, quiet *bool) *cobra.Command {
	var changed bool
	var commit1, commit2 string
	var withDependencies bool

	cmd := &cobra.Command{
		Use:   "build-matrix",
		Short: "Generate build matrix for CI",
		Long:  "Generate build matrix for CI with optional change detection and dependency analysis",
		RunE: func(cmd *cobra.Command, args []string) error {
			manager := api.NewRuntimeManager(*registryPath)

			if err := manager.ScanPackages(); err != nil {
				return fmt.Errorf("failed to scan packages: %w", err)
			}

			// Get build matrix - for now, return all packages as a simple implementation
			var matrix []string
			for _, pkg := range manager.Packages {
				matrix = append(matrix, pkg.Dockerfile)
			}

			// Output as JSON
			data, err := json.MarshalIndent(matrix, "", "  ")
			if err != nil {
				return fmt.Errorf("failed to marshal build matrix: %w", err)
			}
			fmt.Println(string(data))

			return nil
		},
	}

	cmd.Flags().BoolVar(&changed, "changed", false, "Only include changed packages")
	cmd.Flags().StringVar(&commit1, "commit1", "", "First commit hash for comparison")
	cmd.Flags().StringVar(&commit2, "commit2", "", "Second commit hash for comparison")
	cmd.Flags().BoolVar(&withDependencies, "with-dependencies", false, "Include dependencies of changed packages")

	return cmd
}
