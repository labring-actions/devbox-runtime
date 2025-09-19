package commands

import (
	"encoding/json"
	"fmt"

	"github.com/labring-actions/devbox-runtime/tool/api"
	"github.com/spf13/cobra"
)

func NewAnalyzeDependenciesCommand(registryPath, outputFormat *string, quiet *bool) *cobra.Command {
	cmd := &cobra.Command{
		Use:   "analyze-dependencies",
		Short: "Analyze package dependencies",
		Long:  "Analyze dependencies for all packages and generate dependency graph",
		RunE: func(cmd *cobra.Command, args []string) error {
			manager := api.NewRuntimeManager(*registryPath)

			if err := manager.ScanPackages(); err != nil {
				return fmt.Errorf("failed to scan packages: %w", err)
			}

			// Analyze dependencies
			analysis, err := manager.AnalyzeDependencies()
			if err != nil {
				return fmt.Errorf("failed to analyze dependencies: %w", err)
			}

			// Output analysis
			if *outputFormat == "json" {
				data, err := json.MarshalIndent(analysis, "", "  ")
				if err != nil {
					return fmt.Errorf("failed to marshal analysis: %w", err)
				}
				fmt.Println(string(data))
			} else {
				fmt.Printf("Dependency Analysis\n")
				fmt.Printf("===================\n")
				fmt.Printf("Total packages: %d\n", len(analysis.Nodes))
				fmt.Printf("Dependency analysis completed\n")
			}

			return nil
		},
	}

	return cmd
}
