package commands

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/spf13/cobra"
)

func NewValidateBuildCommand(registryPath, outputFormat *string, quiet *bool) *cobra.Command {
	cmd := &cobra.Command{
		Use:   "validate-build <dockerfile>",
		Short: "Validate build configuration",
		Long:  "Validate build configuration for a specific dockerfile",
		Args:  cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			dockerfile := args[0]

			// Check if dockerfile exists
			if _, err := os.Stat(dockerfile); os.IsNotExist(err) {
				return fmt.Errorf("dockerfile not found: %s", dockerfile)
			}

			// Check if dockerfile is in correct location
			if !strings.HasPrefix(dockerfile, "runtimes/") {
				return fmt.Errorf("dockerfile must be in runtimes/ directory: %s", dockerfile)
			}

			// Validate path structure
			parts := strings.Split(dockerfile, "/")
			if len(parts) < 4 {
				return fmt.Errorf("invalid dockerfile path structure: %s", dockerfile)
			}

			// Check for required files
			dir := filepath.Dir(dockerfile)
			projectDir := filepath.Join(dir, "project")
			if _, err := os.Stat(projectDir); os.IsNotExist(err) {
				if !*quiet {
					fmt.Printf("Warning: project directory not found: %s\n", projectDir)
				}
			}

			if !*quiet {
				fmt.Printf("Build validation passed for: %s\n", dockerfile)
			}

			return nil
		},
	}

	return cmd
}
