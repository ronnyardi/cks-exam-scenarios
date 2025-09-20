#!/bin/bash

# Verify that both deployments have been scaled down to 0 replicas
if kubectl get deployments -n falco-test | grep 'monstrous-kraken' | grep -q '0/0'; then
  if kubectl get deployments -n falco-test | grep 'zany-smile' | grep -q '0/0'; then
    exit 0
  fi
fi

exit 1