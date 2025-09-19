package commands

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
)

// TODO: refactor this, use dockerfile.template to generate the dockerfile
func applyCNModifications(dockerfile string) error {
	// Find the update_cn_dockerfile.sh script
	scriptPath, err := findUpdateScript(dockerfile)
	if err != nil {
		return fmt.Errorf("failed to find update_cn_dockerfile.sh script: %w", err)
	}

	// Check if script exists and is executable
	if _, err := os.Stat(scriptPath); os.IsNotExist(err) {
		return fmt.Errorf("update_cn_dockerfile.sh script not found at: %s", scriptPath)
	}

	// Make sure script is executable
	if err := os.Chmod(scriptPath, 0755); err != nil {
		return fmt.Errorf("failed to make script executable: %w", err)
	}

	// Execute the script
	cmd := exec.Command(scriptPath, dockerfile)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	if err := cmd.Run(); err != nil {
		return fmt.Errorf("failed to execute update script: %w", err)
	}

	fmt.Printf("Applied CN modifications to: %s using script: %s\n", dockerfile, scriptPath)
	return nil
}

func findUpdateScript(dockerfile string) (string, error) {
	// Get the directory containing the dockerfile
	dockerfileDir := filepath.Dir(dockerfile)

	// Look for update_cn_dockerfile.sh in the same directory
	scriptPath := filepath.Join(dockerfileDir, "update_cn_dockerfile.sh")
	if _, err := os.Stat(scriptPath); err == nil {
		return scriptPath, nil
	}

	// Look in parent directories
	currentDir := dockerfileDir
	for {
		parentDir := filepath.Dir(currentDir)
		if parentDir == currentDir {
			break // Reached root
		}

		scriptPath := filepath.Join(currentDir, "update_cn_dockerfile.sh")
		if _, err := os.Stat(scriptPath); err == nil {
			return scriptPath, nil
		}

		currentDir = parentDir
	}

	return "", fmt.Errorf("update_cn_dockerfile.sh script not found in any parent directory")
}
