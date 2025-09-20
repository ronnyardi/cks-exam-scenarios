#!/bin/bash

mkdir -p /opt/seccomp && touch /opt/seccomp/answer

# Create a namespace for the scenario
kubectl create ns seccomp

sleep 2

touch /tmp/finished