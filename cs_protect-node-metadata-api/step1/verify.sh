#!/bin/bash

METADATA_URL="http://169.254.169.254"

# Test metadata-tester pod (should fail)
TESTER_OUTPUT=$(kubectl exec metadata-tester -- curl -s -m5 $METADATA_URL 2>&1)
ACCESSOR_OUTPUT=$(kubectl exec metadata-accessor -- curl -s -m5 $METADATA_URL 2>&1)

if [[ "$TESTER_OUTPUT" == *"command terminated"* && "$ACCESSOR_OUTPUT" == *"Mock Metadata"* ]]; then
  exit 0
else
  exit 1
fi
