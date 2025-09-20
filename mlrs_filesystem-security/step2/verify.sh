#!/bin/bash

# Check the logs for successful writes to writable path
logs=$(kubectl logs secure-app -n secure-fs)

if echo "$logs" | grep -q "Writing to /tmp"; then
  # Attempt to write to a read-only path
  write_test=$(kubectl exec -n secure-fs secure-app -- sh -c 'echo test > /test.txt' 2>&1)
  if echo "$write_test" | grep -q "Read-only"; then
    exit 0
  else
    exit 1
  fi
else
  exit 1
fi
