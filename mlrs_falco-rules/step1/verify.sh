#!/bin/bash

FALCO_LOGS=$(cat /var/log/syslog | grep 'Warning' | grep -m1 '\[P2\] Privileged Container Detected')
EVT_UTC=$(echo "$FALCO_LOGS" | grep -oP 'evt_time=\K[0-9T:\-+.Z]+')

if [[ -n "$FALCO_LOGS" && -n "$EVT_UTC" ]]; then
  exit 0
fi
  exit 1