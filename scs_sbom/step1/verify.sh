#!/bin/bash

# Verify if the deployment is using the patched image
DEPLOYMENT_IMAGE=$(kubectl get deployment morc-api -n team-supply -o jsonpath='{.spec.template.spec.containers[0].image}')
TRIVY_SCAN=$(trivy image --quiet --no-progress "$DEPLOYMENT_IMAGE")

if ! echo "$TRIVY_SCAN" | grep -q "Clean"; then
  echo "New image is still vulnerable"
  exit 1
fi

CYCLONE_DX_OUTPUT=$(jq -r '.vulnerabilities | length' /tmp/morc-api-patched.json)

if [[ "$CYCLONE_DX_OUTPUT" -eq 0 ]]; then
  echo "No vulnerabilities found in CycloneDX report"
  exit 0
else
  echo "Vulnerabilities found in CycloneDX report: $CYCLONE_DX_OUTPUT"
  exit 1
fi
