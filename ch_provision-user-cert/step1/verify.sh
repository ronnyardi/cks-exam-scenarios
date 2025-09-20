#!/bin/bash

# Fetch the CSR for the user 'jack'
csr=$(kubectl get csr jack -o jsonpath='{.status.certificate}' | base64 -d 2>/dev/null)

# Check if the context for the user 'jack' exists
kcc=$(kubectl config get-contexts -o name | grep -w "jack")

# Check if both csr and kcc are non-empty
if [[ -n "$csr" && -n "$kcc" ]]; then
  exit 0
else
  exit 1
fi
