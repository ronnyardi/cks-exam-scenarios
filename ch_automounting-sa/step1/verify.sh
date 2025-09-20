#!/bin/bash

ns_exists=$(kubectl get namespace poc-sa-mount)
token_exists=$(kubectl exec -n poc-sa-mount not-secure -- cat /var/run/secrets/kubernetes.io/serviceaccount/token)

if [[ -n "$ns_exists" && -n "$token_exists" ]]; then
  exit 0
else
  exit 1
fi
