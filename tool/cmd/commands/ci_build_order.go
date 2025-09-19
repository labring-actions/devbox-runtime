package commands

import (
	"encoding/json"
	"fmt"

	"github.com/labring-actions/devbox-runtime/tool/api"
	"github.com/spf13/cobra"
)

func NewBuildOrderCommand(registryPath, outputFormat *string, quiet *bool) *cobra.Command {
	cmd := &cobra.Command{
		Use:   "build-order",
		Short: "Get build order based on dependencies",
		Long:  "Get the build order for packages based on their dependencies",
		RunE: func(cmd *cobra.Command, args []string) error {
			manager := api.NewRuntimeManager(*registryPath)

			if err := manager.ScanPackages(); err != nil {
				return fmt.Errorf("failed to scan packages: %w", err)
			}

			// Get build order
			order, err := manager.GetBuildOrder()
			if err != nil {
				return fmt.Errorf("failed to get build order: %w", err)
			}

			// Output build order
			if *outputFormat == "json" {
				data, err := json.MarshalIndent(order, "", "  ")
				if err != nil {
					return fmt.Errorf("failed to marshal build order: %w", err)
				}
				fmt.Println(string(data))
			} else {
				fmt.Printf("Build Order\n")
				fmt.Printf("===========\n")
				for i, target := range order {
					fmt.Printf("%d. %s\n", i+1, target)
				}
			}

			return nil
		},
	}

	return cmd
}
