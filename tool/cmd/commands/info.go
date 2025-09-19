package commands

import (
	"fmt"

	"github.com/labring-actions/devbox-runtime/tool/api"
	"github.com/spf13/cobra"
)

func NewInfoCommand(registryPath, outputFormat *string, quiet *bool) *cobra.Command {
	cmd := &cobra.Command{
		Use:   "info <name> [version]",
		Short: "Show detailed information about a package",
		Long:  "Show detailed information about a specific package and version",
		Args:  cobra.MinimumNArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			manager := api.NewRuntimeManager(*registryPath)

			if err := manager.ScanPackages(); err != nil {
				return fmt.Errorf("failed to scan packages: %w", err)
			}

			name := args[0]
			version := ""
			if len(args) > 1 {
				version = args[1]
			}

			// Find package
			var pkg *api.PackageInfo
			var err error

			if version != "" {
				pkg, err = manager.GetPackage(name, version)
			} else {
				// Find latest version
				packages := manager.ListPackages("")
				for _, p := range packages {
					if p.Name == name {
						if pkg == nil || p.Version > pkg.Version {
							pkg = p
						}
					}
				}
				if pkg == nil {
					err = fmt.Errorf("package %s not found", name)
				}
			}

			if err != nil {
				return err
			}

			if *outputFormat == "json" {
				return outputPackageInfoJSON(pkg)
			}

			// Output package info in table format
			fmt.Printf("Package Information\n")
			fmt.Printf("==================\n")
			fmt.Printf("Name:         %s\n", pkg.DisplayName)
			fmt.Printf("Internal Name: %s\n", pkg.Name)
			fmt.Printf("Version:      %s\n", pkg.Version)
			fmt.Printf("Kind:         %s\n", pkg.Kind)
			fmt.Printf("Port:         %d\n", pkg.Port)
			fmt.Printf("Base Image:   %s\n", pkg.BaseImage)
			fmt.Printf("Dockerfile:   %s\n", pkg.Dockerfile)
			fmt.Printf("Project:      %s\n", pkg.Project)
			if pkg.Entrypoint != "" {
				fmt.Printf("Entrypoint:   %s\n", pkg.Entrypoint)
			}

			return nil
		},
	}

	return cmd
}
