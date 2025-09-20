#!/bin/bash

# Get the logs of the Pod and search for secret names
res=$(kubectl logs secret-list -n secure-api | grep -E "secret1|secret2|secret3")

# Check if result exist
if [[ -n "$res" ]]; then
  exit 0
else
  exit 1
fi