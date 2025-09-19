package commands

import (
	"fmt"

	"github.com/labring-actions/devbox-runtime/tool/api"
	"github.com/spf13/cobra"
)

func NewGenerateMetaCommand(registryPath, outputFormat *string, quiet *bool) *cobra.Command {
	cmd := &cobra.Command{
		Use:   "generate-meta",
		Short: "Generate runtime metadata from scanned packages",
		Long:  "Generate runtime metadata from scanned packages and output to config files",
		RunE: func(cmd *cobra.Command, args []string) error {
			manager := api.NewRuntimeManager(*registryPath)

			if err := manager.ScanPackages(); err != nil {
				return fmt.Errorf("failed to scan packages: %w", err)
			}

			meta, err := manager.GenerateMeta()
			if err != nil {
				return fmt.Errorf("failed to generate metadata: %w", err)
			}

			if *outputFormat == "json" {
				return outputMetaJSON(meta)
			}

			// Output summary
			fmt.Printf("Generated metadata for %d packages\n", len(manager.Packages))
			fmt.Printf("Frameworks: %d\n", len(meta.Runtime.Framework))
			fmt.Printf("Languages: %d\n", len(meta.Runtime.Language))
			fmt.Printf("OS: %d\n", len(meta.Runtime.OS))
			fmt.Printf("Custom: %d\n", len(meta.Runtime.Custom))

			return nil
		},
	}

	return cmd
}
