#!/bin/bash

kubectl run verify-privileged --image=busybox --overrides='
{
  "apiVersion": "v1",
  "spec": {
    "containers": [
      {
        "name": "verify-privileged",
        "image": "busybox",
        "securityContext": {
          "privileged": true
        },
        "command": ["/bin/sh", "-c", "sleep 300"]
      }
    ],
    "restartPolicy": "Never"
  }
}'

while true; do kubectl get pod verify-privileged -o jsonpath='{.status.phase}' | grep -q 'Running' && break; sleep 1; done

FALCO_LOGS=$(cat /var/log/syslog | grep 'Warning' | grep '\[P2\] Privileged Container Detected' | grep -m1 'verify-privileged')
EVT_UTC=$(echo "$FALCO_LOGS" | grep -oP 'evt_time=\K[0-9T:\-+.Z]+')

if [[ -n "$FALCO_LOGS" && -n "$EVT_UTC" ]]; then
  exit 0
fi
  exit 1

kubectl delete pod verify-privileged --force --grace-period=0