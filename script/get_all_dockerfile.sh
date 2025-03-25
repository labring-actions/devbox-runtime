#!/bin/bash
DOCKERFILES=$(find . -name "Dockerfile" | sed 's|^\./||')
ARRAY_OUTPUT="["
FIRST=true

for DOCKERFILE in $DOCKERFILES; do
  if [ "$FIRST" = true ]; then
    ARRAY_OUTPUT+="\"$DOCKERFILE\""
    FIRST=false
  else
    ARRAY_OUTPUT+=",\"$DOCKERFILE\""
  fi
done

ARRAY_OUTPUT+="]"
echo "$ARRAY_OUTPUT"
