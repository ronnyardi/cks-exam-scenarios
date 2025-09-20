#!/bin/bash

# Read the expected image digests from the answer file
readarray -t expected_digests < /opt/digest/answer

# Get the current images of all pods in the digest namespace
current_images=$(kubectl get pods -n digest -o=jsonpath='{range .items[*]}{.spec.containers[*].image}{"\n"}{end}')

# Verify if the current images match the expected digests
for expected_digest in "${expected_digests[@]}"; do
  if ! grep -q "$expected_digest" <<< "$current_images"; then
    exit 1
  fi
done

exit 0