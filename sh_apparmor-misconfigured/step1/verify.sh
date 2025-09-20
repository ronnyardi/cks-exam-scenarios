#!/bin/bash

status=$(kubectl get pod -n apparmor -lapp=corndog-service -o jsonpath="{.items[0].status.phase}" 2>&1)

if [[ $status == "Running" ]]; then
  exit 0
else
  exit 1
fi