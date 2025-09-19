package commands

import (
	"github.com/spf13/cobra"
)

func NewCICommand(registryPath, outputFormat *string, quiet *bool) *cobra.Command {
	cmd := &cobra.Command{
		Use:   "ci",
		Short: "CI/CD commands for building and managing runtime packages",
		Long:  "CI/CD commands for building, analyzing, and managing runtime packages in CI/CD pipelines",
	}

	// Add CI subcommands
	cmd.AddCommand(NewBuildMatrixCommand(registryPath, outputFormat, quiet))
	cmd.AddCommand(NewImageNameCommand(registryPath, outputFormat, quiet))
	cmd.AddCommand(NewBuildCommand(registryPath, outputFormat, quiet))
	cmd.AddCommand(NewBuildAndPushCommand(registryPath, outputFormat, quiet))
	cmd.AddCommand(NewGenerateConfigCommand(registryPath, outputFormat, quiet))
	cmd.AddCommand(NewGenerateStartupCommand(registryPath, outputFormat, quiet))
	cmd.AddCommand(NewValidateBuildCommand(registryPath, outputFormat, quiet))
	cmd.AddCommand(NewUpdateBaseImageCommand(registryPath, outputFormat, quiet))
	cmd.AddCommand(NewAnalyzeDependenciesCommand(registryPath, outputFormat, quiet))
	cmd.AddCommand(NewBuildOrderCommand(registryPath, outputFormat, quiet))
	cmd.AddCommand(NewValidateDependenciesCommand(registryPath, outputFormat, quiet))
	cmd.AddCommand(NewDependencyGraphCommand(registryPath, outputFormat, quiet))

	return cmd
}
