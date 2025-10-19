#!/bin/bash

GRANULAR_POLICY="/etc/kubernetes/audit/audit-granular.yaml"

POD_LEVEL=$(yq '.rules[] | select(.resources[].resources[] == "pods") | .level' "$GRANULAR_POLICY")
CONFIGMAP_LEVEL=$(yq '.rules[] | select(.resources[].resources[] == "configmaps") | .level' "$GRANULAR_POLICY")
SECRET_LEVEL=$(yq '.rules[] | select(.resources[].resources[] == "secrets") | .level' "$GRANULAR_POLICY")
OTHERS_LEVEL=$(yq '.rules[] | select(length == 1) | .level' "$GRANULAR_POLICY")

if [[ "$POD_LEVEL" == "RequestResponse" ]] && \
   [[ "$CONFIGMAP_LEVEL" == "None" ]] && \
   [[ "$SECRET_LEVEL" == "None" ]] && \
   [[ "$OTHERS_LEVEL" == "Metadata" ]]; then
  echo "Granular audit policy is correctly configured."
  exit 0
else
  echo "Granular audit policy has incorrect levels."
  echo "Pods: $POD_LEVEL | ConfigMaps: $CONFIGMAP_LEVEL | Secrets: $SECRET_LEVEL | Others: $OTHERS_LEVEL"
  exit 1
fi