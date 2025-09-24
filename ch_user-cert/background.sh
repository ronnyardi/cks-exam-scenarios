#!/bin/bash

sudo apt-get install -y faketime

mkdir bg
cd bg

USER="user-dev"
CLUSTER_NAME="kubernetes"
CONTEXT_NAME="${USER}-context"
CA_CERT="/etc/kubernetes/pki/ca.crt"
CA_KEY="/etc/kubernetes/pki/ca.key"
CLUSTER_SERVER="https://127.0.0.1:6443"

# Generate key pair and sign the certs
openssl genrsa -out ${USER}.key 2048
openssl req -new -key ${USER}.key -out ${USER}.csr -subj "/CN=${USER}"

# Sign with expired date
faketime '2024-09-01 00:00:00' openssl x509 -req -in ${USER}.csr -CA $CA_CERT -CAkey $CA_KEY -CAcreateserial -out ${USER}.crt -days 365

# Add expired user
kubectl config set-credentials $USER --client-certificate=${USER}.crt --client-key=${USER}.key --embed-certs=true
kubectl config set-context $CONTEXT_NAME --cluster=$CLUSTER_NAME --user=$USER

sleep 2

cd ../
rm -r bg

touch /tmp/finished