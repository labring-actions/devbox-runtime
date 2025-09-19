#!/bin/bash

# Update all command files to use pointers
find cmd/commands -name "*.go" -not -name "output.go" -not -name "cn_modifications.go" | while read file; do
    echo "Updating $file"

    # Update function signatures
    sed -i '' 's/func New\([A-Za-z]*\)Command(registryPath, outputFormat string, quiet bool)/func New\1Command(registryPath, outputFormat *string, quiet *bool)/g' "$file"

    # Update variable references
    sed -i '' 's/manager := api.NewRuntimeManager(registryPath)/manager := api.NewRuntimeManager(*registryPath)/g' "$file"
    sed -i '' 's/if outputFormat == "json"/if *outputFormat == "json"/g' "$file"
    sed -i '' 's/if !quiet/if !*quiet/g' "$file"
done

echo "All command files updated!"
