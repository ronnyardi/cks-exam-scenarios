#!/bin/bash

# Verify that the Pod's write operation is denied
logs=$(kubectl exec -n apparmor pods/deny-write-pod -- touch /test.txt)

if [[ "$logs" == *"Permission denied"* ]]; then
  exit 0
else
  exit 1
fi