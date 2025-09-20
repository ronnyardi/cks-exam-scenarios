#!/bin/bash

# Create a namespace for the scenario
kubectl create namespace limited

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: dark-illusion
  namespace: limited
spec:
  containers:
  - image: bitnami/nginx
    name: nginx
EOF

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: prime-ships
  namespace: limited
spec:
  containers:
  - image: nginx:1.23.1
    name: nginx
EOF

mkdir /opt/non-root && touch /opt/non-root/answer

sleep 3 # some long running background task

touch /tmp/finished