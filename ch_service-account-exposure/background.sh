#!/bin/bash

# Create answer file
mkdir /opt/secure-api && touch /opt/secure-api/answer

# Create a namespace for testing
kubectl create namespace secure-api

# Create a service account
kubectl create serviceaccount call-api -n secure-api

# Deploy a secret for testing
kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: secret1
type: Opaque
data:
  password: cGFzc3dvcmQ=
---
apiVersion: v1
kind: Secret
metadata:
  name: secret2
type: Opaque
data:
  password: QWRtaW5AMTIzNAo=
---
apiVersion: v1
kind: Secret
metadata:
  name: secret3
type: Opaque
data:
  password: MTIzNDU2Nzg4NzY1NDMyMQo=
EOF


# Finish
sleep 3
touch /tmp/finished