package commands

import (
	"fmt"
	"strings"

	"github.com/spf13/cobra"
)

func NewImageNameCommand(registryPath, outputFormat *string, quiet *bool) *cobra.Command {
	cmd := &cobra.Command{
		Use:   "image-name <dockerfile> <registry> <namespace> <tag>",
		Short: "Generate image name for build",
		Long:  "Generate full image name for a given dockerfile, registry, namespace, and tag",
		Args:  cobra.ExactArgs(4),
		RunE: func(cmd *cobra.Command, args []string) error {
			dockerfile := args[0]
			registry := args[1]
			namespace := args[2]
			tag := args[3]

			// Extract image name from dockerfile path
			parts := strings.Split(dockerfile, "/")
			if len(parts) < 3 {
				return fmt.Errorf("invalid dockerfile path: %s", dockerfile)
			}

			// Format: runtimes/kind/name/version/Dockerfile
			name := parts[2]
			version := parts[3]

			imageName := fmt.Sprintf("%s-%s", name, version)

			// Generate full image name
			if strings.Contains(registry, "ghcr.io") {
				fullName := fmt.Sprintf("%s/%s/devbox/%s:%s", registry, namespace, imageName, tag)
				fmt.Println(fullName)
			} else {
				// ACR format
				fullName := fmt.Sprintf("%s/%s/%s:%s", registry, namespace, imageName, tag)
				fmt.Println(fullName)
			}

			return nil
		},
	}

	return cmd
}
