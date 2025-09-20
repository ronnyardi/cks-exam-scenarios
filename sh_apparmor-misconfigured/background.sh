#!/bin/bash

# Create a namespace for the scenario
kubectl create namespace apparmor

# Install AppArmor utilities if not already installed
sudo apt-get update
sudo apt-get install -y apparmor-utils

cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: corndog-service
  name: corndog-service
  namespace: apparmor
spec:
  replicas: 2
  selector:
    matchLabels:
      app: corndog-service
  template:
    metadata:
      labels:
        app: corndog-service
    spec:
      securityContext:
        appArmorProfile:
          type: Localhost
          localhostProfile: dockerz-default
      containers:
      - command:
        - sh
        - -c
        - sleep 1d
        image: busybox
        name: busybox
EOF

sleep 2

touch /tmp/finished