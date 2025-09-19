package commands

import (
	"fmt"
	"os"
	"path/filepath"

	"github.com/spf13/cobra"
)

func NewGenerateStartupCommand(registryPath, outputFormat *string, quiet *bool) *cobra.Command {
	var outputPath string

	cmd := &cobra.Command{
		Use:   "generate-startup",
		Short: "Generate startup script for containers",
		Long:  "Generate startup script for containers with SSH daemon and environment setup",
		RunE: func(cmd *cobra.Command, args []string) error {
			startupScript := `#!/bin/bash

# Set hostname if SEALOS_DEVBOX_NAME is provided
if [ ! -z "${SEALOS_DEVBOX_NAME}" ]; then
    echo "${SEALOS_DEVBOX_NAME}" > /etc/hostname
fi

# Store pod UID
echo "${SEALOS_DEVBOX_POD_UID}" > /usr/start/pod_id

# Start the SSH daemon
/usr/sbin/sshd

# Keep container running
sleep infinity
`

			// Create output directory if it doesn't exist
			outputDir := filepath.Dir(outputPath)
			if err := os.MkdirAll(outputDir, 0755); err != nil {
				return fmt.Errorf("failed to create output directory: %w", err)
			}

			// Write startup script
			if err := os.WriteFile(outputPath, []byte(startupScript), 0755); err != nil {
				return fmt.Errorf("failed to write startup script: %w", err)
			}

			if !*quiet {
				fmt.Printf("Generated startup script: %s\n", outputPath)
			}

			return nil
		},
	}

	cmd.Flags().StringVar(&outputPath, "output", "/usr/start/startup.sh", "Output path for startup script")

	return cmd
}
