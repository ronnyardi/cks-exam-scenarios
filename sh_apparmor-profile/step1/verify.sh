#!/bin/bash

# Capture both stdout and stderr
logs=$(kubectl exec -n apparmor pods/deny-write-pod -- touch /test.txt 2>&1)

if [[ "$logs" == *"Permission denied"* ]]; then
  exit 0
else
  exit 1
fi