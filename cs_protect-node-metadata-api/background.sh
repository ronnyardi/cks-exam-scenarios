#!/bin/bash

# Create mock metadata API server
kubectl create namespace metadata

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: metadata-index
  namespace: metadata
data:
  index.html: |
    <html>
      <head><title>Mock Metadata</title></head>
      <body>
        <h1>This is a mock AWS metadata server, welcome?</h1>
      </body>
    </html>
EOF

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: mock-metadata-server
  name: mock-metadata-server
  namespace: metadata
spec:
  hostNetwork: true
  containers:
  - image: nginx
    name: mock-metadata-server
    ports:
    - containerPort: 80
    resources: {}
    volumeMounts:
    - name: html
      mountPath: /usr/share/nginx/html/index.html
      subPath: index.html
  volumes:
  - name: html
    configMap:
      name: metadata-index
EOF

# Bind a fake address for the node metadata API
ip addr add 169.254.169.254/32 dev enp1s0

# Run a pod metadata-accessor
kubectl run metadata-accessor --image alpine/curl --labels role=metadata-accessor -- sleep 1h
kubectl run metadata-tester --image alpine/curl -- sleep 1h

sleep 5 # some long running background task

touch /tmp/finished