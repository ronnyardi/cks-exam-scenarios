#!/bin/bash

# Check if the Pod is created and running
if kubectl get pod secure-app -n secure-fs &>/dev/null; then
  # Check if the container has read-only root filesystem enabled
  readonly_fs=$(kubectl get pod secure-app -n secure-fs -o=jsonpath='{.spec.containers[0].securityContext.readOnlyRootFilesystem}')
  if [[ "$readonly_fs" == "true" ]]; then
    exit 0
  else
    exit 1
  fi
else
  exit 1
fi
