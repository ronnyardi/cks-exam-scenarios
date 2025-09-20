#!/bin/bash

# Create a namespace for the scenario
kubectl create namespace apparmor

# Install AppArmor utilities if not already installed
sudo apt-get update
sudo apt-get install -y apparmor-utils

sleep 2

touch /tmp/finished