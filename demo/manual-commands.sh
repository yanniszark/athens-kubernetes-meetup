#!/bin/bash

set -e

####################################
## In a new window, show progress ##
####################################

tmux
watch "kubectl describe -n rook-cassandra clusters.cassandra.rook.io rook-cassandra | tail -n 20"
watch "kubectl exec -n rook-cassandra rook-cassandra-europe-west1-europe-west1-b-0 -- nodetool status"

####################################


# Go to demo folder
cd ~/Desktop/diplom/presentation/demo/

# Provision GKE Cluster
./gke-provision.sh

# Apply operator manifest
kubectl apply -f manifests/operator.yaml

# Show cluster manifest
view manifests/cluster.yaml

# Apply cluster manifest
kubectl apply -f manifests/cluster.yaml
