#!/bin/bash

# Create a namespace for the scenario
kubectl create namespace restricted

# Create a deployment for the target application
kubectl create deployment commerce-frontend -n restricted --replicas 3 --image nginx --port 80

kubectl expose deployment commerce-frontend -n restricted --type ClusterIP

sleep 5 # some long running background task

touch /tmp/finished