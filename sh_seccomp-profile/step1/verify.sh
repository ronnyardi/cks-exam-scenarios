#!/bin/bash

# Copy the seccomp profile from the node to the local machine
scp node01:/var/lib/kubelet/seccomp/seccomp-audit.json /tmp/seccomp-audit.json 2>/dev/null

# Check if the seccomp profile was successfully copied
if [ -e /tmp/seccomp-audit.json ]; then
  # File exists, remove the copied file and exit with success status
  rm /tmp/seccomp-audit.json
  exit 0
else
  # File does not exist, exit with failure status
  exit 1
fi
