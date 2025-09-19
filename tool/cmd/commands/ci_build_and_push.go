package commands

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
)

func NewBuildAndPushCommand(registryPath, outputFormat *string, quiet *bool) *cobra.Command {
	var cn bool

	cmd := &cobra.Command{
		Use:   "build-and-push <dockerfile> <image-name1> <image-name2>",
		Short: "Build and push image with multiple tags",
		Long:  "Build a Docker image and push it with multiple tags",
		Args:  cobra.ExactArgs(3),
		RunE: func(cmd *cobra.Command, args []string) error {
			dockerfile := args[0]
			imageName1 := args[1]
			imageName2 := args[2]

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

			// Build and push command with multiple tags
			buildCmd := fmt.Sprintf("docker buildx build --push --file %s --platform linux/amd64 --tag %s --tag %s .",
				dockerfile, imageName1, imageName2)

			if !*quiet {
				fmt.Printf("Building and pushing image with tags: %s, %s\n", imageName1, imageName2)
				fmt.Printf("Command: %s\n", buildCmd)
			}

			// In a real implementation, you would execute the build command here
			// For now, just output the command
			fmt.Println(buildCmd)

			return nil
		},
	}

	cmd.Flags().BoolVar(&cn, "cn", false, "Apply CN-specific modifications")

	return cmd
}
