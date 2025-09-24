#!/bin/bash

# Fetch the CSR for the user 'jack'
access=$(kubectl get pod --as user-dev 2>&1)

# Check if both csr and kcc are non-empty
if [[ "$access" == *"No resources found in default namespace"* ]]; then
  exit 0
else
  exit 1
fi
