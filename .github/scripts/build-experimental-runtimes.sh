#!/usr/bin/env bash
set -euo pipefail

FILES=$(find experimental/runtimes -type f -name Dockerfile -not -path "*/base-tools/*" -not -path "*/configure-tools/*" 2>/dev/null) || true
if [ -z "$FILES" ]; then
  echo "No runtime Dockerfiles found"
  exit 0
fi

for f in $FILES; do
  echo "----"; echo "Found runtime Dockerfile: $f"
  dir=$(dirname "$f")
  parent1=$(basename "$(dirname "$dir")") || true
  parent2=$(basename "$(dirname "$(dirname "$dir")")") || true
  image_name="${parent2}-${parent1}"
  image_name=${image_name#/}
  image_name=${image_name//\//-}

  TAG="${IMAGE_TAG:-}"
  PLATFORMS="${PLATFORMS:-}"
  ADD_LATEST="${ADD_LATEST:-false}"
  REPO_OWNER="${REPO_OWNER:-${GITHUB_REPOSITORY_OWNER}}"
  REPO_NAME="${REPO_NAME:-devbox-expt-runtime}"

  BUILD_ARGS="--build-arg REPO_OWNER=${REPO_OWNER} --build-arg REPO_NAME=${REPO_NAME}"

  if [ "${GITHUB_EVENT_NAME:-}" = "workflow_dispatch" ]; then
    TAGFLAGS="-t ghcr.io/${REPO_OWNER}/${REPO_NAME}/${image_name}:${TAG}"
    if [ "$ADD_LATEST" = 'true' ]; then TAGFLAGS+=" -t ghcr.io/${REPO_OWNER}/${REPO_NAME}/${image_name}:latest"; fi
    echo "PUSH: building and pushing ${REPO_NAME}/${image_name}:${TAG} for platforms ${PLATFORMS}"
    eval docker buildx build --progress=plain --platform "$PLATFORMS" $BUILD_ARGS $TAGFLAGS --push "$dir"
  else
    echo "PR: building ${REPO_NAME}/${image_name} per-arch (no push)"
    IFS=',' read -r -a ARCHS <<< "${PLATFORMS//linux\//}"
    for a in "${ARCHS[@]}"; do
      echo "  Building arch: $a"
      # For PR builds we load single-arch images into the builder node for validation
      docker buildx build --progress=plain --platform linux/$a $BUILD_ARGS -t ghcr.io/${REPO_OWNER}/${REPO_NAME}/${image_name}:pr-${PR_NUMBER:-unknown}-$a --load "$dir"
    done
  fi
done
