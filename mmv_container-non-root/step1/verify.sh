#!/bin/bash

# Verify that the Pod is running as a non-root user
pod_status=$(kubectl get pod dark-illusion -n limited -o jsonpath='{.status.phase}')
run_as=$(kubectl get pod dark-illusion -n limited -o jsonpath='{.spec.containers[0].securityContext.runAsNonRoot}')
res=$(cat /opt/non-root/answer)

if [[ "$pod_status" == "Running" && "$run_as" == "true" ]]; then
  if [[ "$res" == "prime-ships" ]]; then
    exit 0
  else
    exit 1
  fi
else
  exit 1
fi