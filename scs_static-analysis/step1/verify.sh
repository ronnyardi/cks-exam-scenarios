#!/bin/bash

# Paths to the original files
original_files=(
  "/opt/static-analysis/deployment.yaml" # INSECURE
  "/opt/static-analysis/service.yaml"
  "/opt/static-analysis/role.yaml" # INSECURE
  "/opt/static-analysis/pod.yaml" # INSECURE
  "/opt/static-analysis/Dockerfile1" # INSECURE
  "/opt/static-analysis/Dockerfile2" # INSECURE
  "/opt/static-analysis/Dockerfile3"
)

# Paths that should have been renamed to .insecure
insecure_files=(
  "/opt/static-analysis/deployment.yaml.insecure"
  "/opt/static-analysis/role.yaml.insecure"
  "/opt/static-analysis/pod.yaml.insecure"
  "/opt/static-analysis/Dockerfile1.insecure"
  "/opt/static-analysis/Dockerfile2.insecure"
)

# Check if the insecure files have been renamed correctly
for insecure_file in "${insecure_files[@]}"; do
  if [[ ! -f "$insecure_file" ]]; then
    exit 1
  fi
done

# Check that the secure files have not been renamed
if [[ -f "/opt/static-analysis/service.yaml.insecure" ]] || [[ -f "/opt/static-analysis/Dockerfile3.insecure" ]]; then
  exit 1
fi

exit 0
