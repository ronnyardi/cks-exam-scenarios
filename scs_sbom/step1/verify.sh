#!/bin/bash

# Verify if the deployment is using the patched image
DEPLOYMENT_IMAGE=$(kubectl get deployment morc-api -n team-supply -o jsonpath='{.spec.template.spec.containers[0].image}')
CYCLONE_DX_OUTPUT=$(trivy image "$DEPLOYMENT_IMAGE" --quiet --no-progress --security-checks vuln --format cyclonedx | jq -r '.vulnerabilities | length')
if [[ -f /tmp/morc-api-patched.json ]]; then
  ANSWER_OUTPUT=$(jq -r '.vulnerabilities | length' /tmp/morc-api-patched.json)
else
  echo "Patched SBOM file not found"
  exit 1
fi

if [[ "$CYCLONE_DX_OUTPUT" -eq 0 && "$ANSWER_OUTPUT" -eq 0 ]]; then
  echo "No vulnerabilities found in CycloneDX report"
  exit 0
else
  echo "Vulnerabilities found in CycloneDX report: $CYCLONE_DX_OUTPUT"
  exit 1
fi
