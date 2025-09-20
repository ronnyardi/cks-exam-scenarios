#!/bin/bash

# Get runsc version
res=$(runsc --version 2>/dev/null)

# Check for gVisor runtime class in Kubernetes
rc=$(kubectl get runtimeclasses.node.k8s.io gvisor 2>/dev/null)

# Check if both `runsc` version and `gvisor` runtime class exist
if [[ -n "$res" && -n "$rc" ]]; then
  exit 0
else
  exit 1
fi
