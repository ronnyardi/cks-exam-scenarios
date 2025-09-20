#!/bin/bash

# Get the logs of the Pod and search for "Failure" or "403" errors
res=$(kubectl logs secret-list -n secure-api | grep -E "Failure|403")

# Check if any matches were found
if [[ -n "$res" ]]; then
  exit 0
else
  exit 1
fi
