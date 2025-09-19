package commands

import (
	"fmt"
	"os"
	"text/tabwriter"

	"github.com/labring-actions/devbox-runtime/tool/api"
	"github.com/spf13/cobra"
)

func NewDependenciesCommand(registryPath, outputFormat *string, quiet *bool) *cobra.Command {
	cmd := &cobra.Command{
		Use:   "dependencies <name> [version]",
		Short: "Show dependencies for a package",
		Long:  "Show dependencies for a specific package and version",
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

			// Get dependencies
			deps, err := manager.GetDependencies(pkg.Name, pkg.Version)
			if err != nil {
				return fmt.Errorf("failed to get dependencies: %w", err)
			}

			if *outputFormat == "json" {
				return outputDependenciesJSON(deps)
			}

			// Output dependencies in table format
			fmt.Printf("Dependencies for %s %s\n", pkg.DisplayName, pkg.Version)
			fmt.Printf("========================\n")
			if len(deps.Dependencies) == 0 {
				fmt.Println("No dependencies")
				return nil
			}

			w := tabwriter.NewWriter(os.Stdout, 0, 0, 2, ' ', 0)
			fmt.Fprintln(w, "Name\tVersion\tKind")
			fmt.Fprintln(w, "----\t-------\t----")
			for _, dep := range deps.Dependencies {
				fmt.Fprintf(w, "%s\t%s\t%s\n", dep.Name, dep.Version, dep.Kind)
			}
			w.Flush()

			return nil
		},
	}

	return cmd
}
