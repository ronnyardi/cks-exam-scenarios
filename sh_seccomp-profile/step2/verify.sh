#!/bin/bash

# Check if the answer file exists
answer_file="/opt/seccomp/answer"
if [[ ! -f "$answer_file" ]]; then
  exit 1
fi

# Read the last 50 lines from the answer file
lines=$(tail -50 "$answer_file")

# Check each line for the "syscall" string
while IFS= read -r line; do
  if [[ "$line" != *"syscall"* ]]; then
    exit 1
  fi
done <<< "$lines"

exit 0
