#!/bin/bash

# Get the NetworkPolicy JSON
res=$(kubectl get networkpolicy allow-specific-pods -n restricted -o json)

# Check the conditions
if [[ $(echo "$res" | jq -r .spec.podSelector.matchLabels.app) == "commerce-frontend" ]] &&
   [[ $(echo "$res" | jq -r '.spec.ingress[0].from[0].namespaceSelector.matchLabels["kubernetes.io/metadata.name"]') == "jumpbox" ]] &&
   [[ $(echo "$res" | jq -r .spec.ingress[0].from[0].podSelector.matchLabels.app) == "jumpbox" ]]; then
  exit 0
else
  exit 1
fi