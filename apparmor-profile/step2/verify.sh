#!/bin/bash

# Verify that the Pod's write operation is denied
logs=$(kubectl logs -n apparmor pods/block-chmod-pod 2>&1)

if [[ "$logs" == *"Permission denied"* ]]; then
  exit 0
else
  exit 1
fi