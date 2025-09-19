package commands

import (
	"encoding/json"
	"fmt"
	"os"

	"github.com/labring-actions/devbox-runtime/tool/api"
	"github.com/spf13/cobra"
)

func NewGenerateConfigCommand(registryPath, outputFormat *string, quiet *bool) *cobra.Command {
	var cn bool
	var tag string

	cmd := &cobra.Command{
		Use:   "generate-config",
		Short: "Generate runtime configuration",
		Long:  "Generate runtime configuration files for the registry",
		RunE: func(cmd *cobra.Command, args []string) error {
			manager := api.NewRuntimeManager(*registryPath)

			if err := manager.ScanPackages(); err != nil {
				return fmt.Errorf("failed to scan packages: %w", err)
			}

			// Generate metadata
			meta, err := manager.GenerateMeta()
			if err != nil {
				return fmt.Errorf("failed to generate metadata: %w", err)
			}

			// Output to appropriate file
			outputFile := "config/registry.json"
			if cn {
				outputFile = "config/registry-cn.json"
			}

			data, err := json.MarshalIndent(meta, "", "  ")
			if err != nil {
				return fmt.Errorf("failed to marshal metadata: %w", err)
			}

			if err := os.WriteFile(outputFile, data, 0644); err != nil {
				return fmt.Errorf("failed to write config file: %w", err)
			}

			if !*quiet {
				fmt.Printf("Generated runtime config: %s\n", outputFile)
			}

			return nil
		},
	}

	cmd.Flags().BoolVar(&cn, "cn", false, "Generate CN-specific configuration")
	cmd.Flags().StringVar(&tag, "tag", "latest", "Tag for the configuration")

	return cmd
}
