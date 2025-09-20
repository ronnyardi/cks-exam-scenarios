#!/bin/bash

res=$(cat /opt/gvisor/answer | grep -E "Starting gVisor|Ready!")

if [[ -n "$res" ]]; then
  exit 0
else
  exit 1
fi
