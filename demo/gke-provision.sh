#!/bin/bash

set -e

GCP_USER=${1:-"your email"}
GCP_PROJECT=${2:-"your gcp project"}

gcloud beta container clusters create "cluster" \
--project "$GCP_PROJECT" \
--region "europe-west1" \
--node-locations "europe-west1-b,europe-west1-c" \
--cluster-version "1.11.5-gke.5" \
--machine-type "n1-standard-4" \
--image-type "UBUNTU" \
--disk-type "pd-ssd" --disk-size "20" \
--local-ssd-count "1" \
--num-nodes "4" \
--no-enable-autoupgrade --no-enable-autorepair


# gcloud: Get credentials for new cluster
echo "Getting credentials for newly created cluster..."
gcloud container clusters get-credentials cluster --region=europe-west1

# Setup GKE RBAC
echo "Setting up GKE RBAC..."
kubectl create clusterrolebinding cluster-admin-binding --clusterrole cluster-admin --user "$GCP_USER"


echo "Checking if helm is present on the machine..."
if ! hash helm 2>/dev/null; then
  echo "You need to install helm. See: https://docs.helm.sh/using_helm/#installing-helm"
  exit 1
fi

# Setup Tiller
echo "Setting up Tiller..."
helm init
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'

# Wait for Tiller to become ready
until [[ $(kubectl get deployment tiller-deploy -n kube-system -o 'jsonpath={.status.readyReplicas}') -eq 1 ]];
do
    echo "Waiting for Tiller pod to become Ready..."
    sleep 5
done

# Install local volume provisioner
echo "Installing local volume provisioner..."
helm install --name local-provisioner provisioner
echo "Your disks are ready to use."
