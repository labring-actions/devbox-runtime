package commands

import (
	"fmt"
	"os"
	"strings"

	"github.com/spf13/cobra"
)

func NewUpdateBaseImageCommand(registryPath, outputFormat *string, quiet *bool) *cobra.Command {
	cmd := &cobra.Command{
		Use:   "update-base-image <dockerfile> <base-image-name>",
		Short: "Update base image in Dockerfile",
		Long:  "Update the base image reference in a Dockerfile",
		Args:  cobra.ExactArgs(2),
		RunE: func(cmd *cobra.Command, args []string) error {
			dockerfile := args[0]
			baseImageName := args[1]

			// Read dockerfile
			content, err := os.ReadFile(dockerfile)
			if err != nil {
				return fmt.Errorf("failed to read dockerfile: %w", err)
			}

			// Find and replace FROM line
			lines := strings.Split(string(content), "\n")
			modified := false

			for i, line := range lines {
				if strings.HasPrefix(strings.TrimSpace(line), "FROM ") {
					lines[i] = fmt.Sprintf("FROM %s", baseImageName)
					modified = true
					break
				}
			}

			if !modified {
				return fmt.Errorf("no FROM line found in dockerfile")
			}

			// Write back
			modifiedContent := strings.Join(lines, "\n")
			if err := os.WriteFile(dockerfile, []byte(modifiedContent), 0644); err != nil {
				return fmt.Errorf("failed to write modified dockerfile: %w", err)
			}

			if !*quiet {
				fmt.Printf("Updated base image in %s to: %s\n", dockerfile, baseImageName)
			}

			return nil
		},
	}

	return cmd
}
