#!/bin/bash

# Check the number of input parameters
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <commit1> <commit2>"
  exit 1
fi

# Get the list of Dockerfile differences between the two commits
DIFF_OUTPUT=$(git diff --name-only "$1" "$2" | grep Dockerfile)

# Initialize arrays to store parent directories and file paths
PARENT_DIRS=()
FILE_PATHS=()

# Iterate over the changed files
for FILE_PATH in $DIFF_OUTPUT; do
  # Check if the file exists
  if [[ ! -f "$FILE_PATH" ]]; then
    echo "File '$FILE_PATH' does not exist, skipping."
    continue
  fi
  
  # Get the name of the parent directory of the file
  PARENT_DIR=$(basename "$(dirname "$FILE_PATH")")
  PARENT_DIRS+=("$PARENT_DIR")
  FILE_PATHS+=("$FILE_PATH")
done

# Convert arrays to comma-separated strings
PARENT_DIRS_STRING=$(IFS=,; echo "${PARENT_DIRS[*]}")
DIFF_OUTPUT_STRING=$(IFS=,; echo "${FILE_PATHS[*]}")

# Print results to the console
echo "PARENT_DIRS=$PARENT_DIRS_STRING"
echo "DIFF_OUTPUT=$DIFF_OUTPUT_STRING"

# Write results to environment variables
echo "PARENT_DIRS=$PARENT_DIRS_STRING" >> "$GITHUB_ENV"
echo "DIFF_OUTPUT=$DIFF_OUTPUT_STRING" >> "$GITHUB_ENV"