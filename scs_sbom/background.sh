#!/bin/bash

# Create a directory 
mkdir -p /opt/morc-api
cd /opt/morc-api

# Create example Kubernetes YAML files with potential security issues
cat <<EOF > /opt/morc-api/nginx.conf
server {
    listen 8989;
    server_name localhost;

    location / {
        root /usr/share/nginx/html;
        index index.html;
    }
}
EOF

cat <<EOF > /opt/morc-api/Dockerfile
FROM nginx:1.29.0-alpine

RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 8989
EOF

# Build the Docker image and import into containerd
docker build -t morc-api:0.1-5 .
docker save morc-api:0.1-5 -o /opt/morc-api/morc-api_0.1-5.tar
ctr -n k8s.io images import /opt/morc-api/morc-api_0.1-5.tar

# Deploy the application to Kubernetes
kubectl create namespace team-supply
kubectl create deployment morc-api --image=morc-api:0.1-5 -n team-supply
kubectl rollout status deployment/morc-api -n team-supply
kubectl expose deployment morc-api --type=NodePort --port=8989 -n team-supply

# Install Trivy CLI
sudo apt-get install wget gnupg
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy

sleep 2
touch /tmp/finished