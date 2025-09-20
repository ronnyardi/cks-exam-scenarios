#!/bin/bash

# Create namespace
kubectl create ns digest

# Create pod using alpine:3.17.9
kubectl run -n digest frog-prizzies --image alpine:3.17.9 -- sleep 1d
kubectl run -n digest batlle-pie --image nginx:1.27.0-alpine3.19
kubectl run -n digest salamander-pipe --image busybox:1.35.0 -- sleep 1d

# Create answer file
mkdir /opt/digest && touch /opt/digest/answer

# Wait
sleep 5
touch /tmp/finished