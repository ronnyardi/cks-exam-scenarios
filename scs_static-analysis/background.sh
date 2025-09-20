#!/bin/bash

# Create a directory to hold the files to be inspected
mkdir -p /opt/static-analysis

# Create example Kubernetes YAML files with potential security issues
cat <<EOF > /opt/static-analysis/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: static-sec-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: static-sec-app
  template:
    metadata:
      labels:
        app: static-sec-app
    spec:
      containers:
      - name: static-sec-container
        image: nginx:latest
        ports:
        - containerPort: 80
        securityContext:
          privileged: true
          capabilities:
            add: ["ALL"]
          readOnlyRootFilesystem: false
EOF

cat <<EOF > /opt/static-analysis/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: static-sec-service
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 80
  selector:
    app: static-sec-app
EOF

cat <<EOF > /opt/static-analysis/role.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: static-sec-role
  namespace: default
rules:
- apiGroups: [""]
  resources: ["pods", "secrets"]
  verbs: ["get", "list", "create", "delete"]
EOF

cat <<EOF > /opt/static-analysis/pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: static-sec-pod
spec:
  containers:
  - name: static-sec-container
    image: ubuntu:latest
    command: ["sh", "-c", "apt-get update && apt-get install -y netcat && nc -l -p 8080"]
    securityContext:
      runAsUser: 0
      runAsGroup: 0
      allowPrivilegeEscalation: true
EOF

# Create an example Dockerfile with potential security issues
cat <<EOF > /opt/static-analysis/Dockerfile1
FROM ubuntu:latest

RUN apt-get update && apt-get install -y sudo vim netcat

USER root

CMD ["bash"]
EOF


cat <<EOF > /opt/static-analysis/Dockerfile2
FROM ubuntu:14.04

RUN apt-get update && apt-get install -y wget curl sudo

COPY . /app

WORKDIR /app

USER root
CMD ["./run-app.sh"]
EOF

Cat <<EOF > /opt/static-analysis/Dockerfile3
FROM python:3.9-slim

ENV PYTHONUNBUFFERED=1

COPY requirements.txt /app/
COPY . /app

WORKDIR /app

RUN pip install --no-cache-dir -r requirements.txt
RUN useradd -m myuser

USER myuser

CMD ["python", "app.py"]
EOF


sleep 2
touch /tmp/finished