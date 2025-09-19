package commands

import (
	"fmt"
	"strings"

	"github.com/labring-actions/devbox-runtime/tool/api"
	"github.com/spf13/cobra"
)

func NewDependencyGraphCommand(registryPath, outputFormat *string, quiet *bool) *cobra.Command {
	cmd := &cobra.Command{
		Use:   "dependency-graph",
		Short: "Generate dependency graph visualization",
		Long:  "Generate a Mermaid diagram showing package dependencies",
		RunE: func(cmd *cobra.Command, args []string) error {
			manager := api.NewRuntimeManager(*registryPath)

			if err := manager.ScanPackages(); err != nil {
				return fmt.Errorf("failed to scan packages: %w", err)
			}

			// Get dependency graph
			graph, err := manager.AnalyzeDependencies()
			if err != nil {
				return fmt.Errorf("failed to get dependency graph: %w", err)
			}

			// Output Mermaid diagram
			fmt.Println("```mermaid")
			fmt.Println("graph TD")

			// Add nodes
			for _, node := range graph.Nodes {
				nodeId := strings.ReplaceAll(node.Name, "-", "_")
				nodeLabel := fmt.Sprintf("%s (%s)", node.Name, node.Version)

				// Add node
				fmt.Printf("    %s[\"%s\"]\n", nodeId, nodeLabel)

				// Add dependencies
				for _, dep := range node.Dependencies {
					depId := strings.ReplaceAll(dep, "-", "_")
					fmt.Printf("    %s --> %s\n", depId, nodeId)
				}
			}

			fmt.Println("```")
			return nil
		},
	}

	return cmd
}
