#!/bin/bash

# Create file
mkdir /opt/gvisor && touch /opt/gvisor/answer

# Create a namespace for the scenario
kubectl create namespace sandbox