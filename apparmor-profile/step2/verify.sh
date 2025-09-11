#!/bin/bash

# Verify that the Pod's write operation is denied
logs=$(kubectl logs -n apparmor pods/block-chmod-pod)

if [[ "$logs" == *"Permission denied"* ]]; then
  echo "Y"
  exit 0
else
  exit 1
fi