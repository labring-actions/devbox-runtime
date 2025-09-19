package commands

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
)

func NewBuildCommand(registryPath, outputFormat *string, quiet *bool) *cobra.Command {
	var cn, push bool

	cmd := &cobra.Command{
		Use:   "build <dockerfile> <image-name>",
		Short: "Build and optionally push image",
		Long:  "Build a Docker image and optionally push it to registry",
		Args:  cobra.ExactArgs(2),
		RunE: func(cmd *cobra.Command, args []string) error {
			dockerfile := args[0]
			imageName := args[1]

			// Validate dockerfile exists
			if _, err := os.Stat(dockerfile); os.IsNotExist(err) {
				return fmt.Errorf("dockerfile not found: %s", dockerfile)
			}

			// Apply CN modifications if needed
			if cn {
				if err := applyCNModifications(dockerfile); err != nil {
					return fmt.Errorf("failed to apply CN modifications: %w", err)
				}
			}

			// Build command
			buildCmd := fmt.Sprintf("docker buildx build --file %s --platform linux/amd64 --tag %s", dockerfile, imageName)
			if push {
				buildCmd += " --push"
			}
			buildCmd += " ."

			if !*quiet {
				fmt.Printf("Building image: %s\n", imageName)
				fmt.Printf("Command: %s\n", buildCmd)
			}

			// In a real implementation, you would execute the build command here
			// For now, just output the command
			fmt.Println(buildCmd)

			return nil
		},
	}

	cmd.Flags().BoolVar(&cn, "cn", false, "Apply CN-specific modifications")
	cmd.Flags().BoolVar(&push, "push", false, "Push image to registry")

	return cmd
}
