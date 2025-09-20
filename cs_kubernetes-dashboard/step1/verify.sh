#!/bin/bash

# Get the arguments from the Kubernetes Dashboard pod spec
res=$(kubectl get pod -n kubernetes-dashboard -l k8s-app=kubernetes-dashboard -o jsonpath='{.items[0].spec.containers[0].args}')

# Check if the pod's arguments do not contain the unwanted flags
if echo "$res" | grep -q -- "--insecure-port=9000"; then
  exit 1
fi

if echo "$res" | grep -q -- "--enable-skip-login=true"; then
  exit 1
fi

if echo "$res" | grep -q -- "--enable-insecure-login"; then
  exit 1
fi

# Check if the pod's arguments contain the required flag
if echo "$res" | grep -q -- "--auto-generate-certificates"; then
  exit 0
else
  exit 1
fi
