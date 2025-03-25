#!/bin/bash

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <commit1> <commit2>"
  exit 1
fi

DIFF_OUTPUT=$(git diff --name-only "$1" "$2"|grep Dockerfile)

ARRAY_OUTPUT="["
FIRST=true

for FILE_PATH in $DIFF_OUTPUT; do
  if [[ ! -f "$FILE_PATH" ]]; then
    echo "File $FILE_PATH does not exist, skipping."
    continue
  fi

  if [ "$FIRST" = true ]; then
    ARRAY_OUTPUT+="\"$FILE_PATH\""
    FIRST=false
  else
    ARRAY_OUTPUT+=",\"$FILE_PATH\""
  fi
done

ARRAY_OUTPUT+="]"
echo "$ARRAY_OUTPUT"
