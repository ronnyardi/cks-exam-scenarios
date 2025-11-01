#!/bin/bash

ns_label=$(kubectl get ns dev -o jsonpath='{.metadata.labels.pod-security\.kubernetes\.io/enforce}')

if [[ "$ns_label" == "restricted" ]]; then
  exit 0
else
  exit 1
fi