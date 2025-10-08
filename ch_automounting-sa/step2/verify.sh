#!/bin/bash

pod_exists=$(kubectl get pod -A | grep -w -E 'q1-secure-sa|q2-secure-sa|q3-secure-sa')
answer=$(cat /tmp/ch-answer.txt)

if [[ -n "$pod_exists" && "$answer" == "NO,NO,NO" ]]; then
  exit 0
else
  exit 1
fi
