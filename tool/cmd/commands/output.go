package commands

import (
	"encoding/json"
	"fmt"
	"os"
	"sort"
	"text/tabwriter"

	"github.com/labring-actions/devbox-runtime/tool/api"
)

func outputPackagesJSON(packages []*api.PackageInfo) error {
	data, err := json.MarshalIndent(packages, "", "  ")
	if err != nil {
		return fmt.Errorf("failed to marshal packages: %w", err)
	}
	fmt.Println(string(data))
	return nil
}

func outputPackageInfoJSON(pkg *api.PackageInfo) error {
	data, err := json.MarshalIndent(pkg, "", "  ")
	if err != nil {
		return fmt.Errorf("failed to marshal package info: %w", err)
	}
	fmt.Println(string(data))
	return nil
}

func outputDependenciesJSON(deps *api.PackageDependencies) error {
	data, err := json.MarshalIndent(deps, "", "  ")
	if err != nil {
		return fmt.Errorf("failed to marshal dependencies: %w", err)
	}
	fmt.Println(string(data))
	return nil
}

func outputMetaJSON(meta *api.RuntimeMeta) error {
	data, err := json.MarshalIndent(meta, "", "  ")
	if err != nil {
		return fmt.Errorf("failed to marshal metadata: %w", err)
	}
	fmt.Println(string(data))
	return nil
}

func outputPackagesTable(packages []*api.PackageInfo) error {
	if len(packages) == 0 {
		fmt.Println("No packages found")
		return nil
	}

	// Sort packages by name and version
	sort.Slice(packages, func(i, j int) bool {
		if packages[i].Name == packages[j].Name {
			return packages[i].Version > packages[j].Version
		}
		return packages[i].Name < packages[j].Name
	})

	w := tabwriter.NewWriter(os.Stdout, 0, 0, 2, ' ', 0)
	fmt.Fprintln(w, "Name\tVersion\tKind\tPort\tBase Image")
	fmt.Fprintln(w, "----\t-------\t----\t----\t----------")
	for _, pkg := range packages {
		fmt.Fprintf(w, "%s\t%s\t%s\t%d\t%s\n",
			pkg.DisplayName, pkg.Version, pkg.Kind, pkg.Port, pkg.BaseImage)
	}
	w.Flush()

	return nil
}
