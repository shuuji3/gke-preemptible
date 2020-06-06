#!/usr/bin/env bash

# Deploy kubeIP
#   following doitintl/kubeip - https://github.com/doitintl/kubeip

export GCP_REGION=asia-east1
export GCP_ZONE=asia-east1-a
export GKE_CLUSTER_NAME=preemptible
export PROJECT_ID=$(gcloud config list --format 'value(core.project)')
export KUBEIP_NODEPOOL=stable-pool
export KUBEIP_SELF_NODEPOOL=default-pool

# Create service accounts
gcloud iam service-accounts create kubeip-service-account --display-name "kubeIP"

# Bind roles
gcloud iam roles create kubeip --project $PROJECT_ID --file kubeip/roles.yaml
gcloud projects add-iam-policy-binding $PROJECT_ID --member serviceAccount:kubeip-service-account@$PROJECT_ID.iam.gserviceaccount.com --role projects/$PROJECT_ID/roles/kubeip

# Create Kubernetes Secret
gcloud iam service-accounts keys create key.json \
  --iam-account kubeip-service-account@$PROJECT_ID.iam.gserviceaccount.com
kubectl create secret generic kubeip-key --from-file=key.json -n kube-system
kubectl create clusterrolebinding cluster-admin-binding \
   --clusterrole cluster-admin --user $(gcloud config list --format 'value(core.account)')

# Create a static reserved IP address
gcloud compute addresses create kubeip-ip-0 --project=$PROJECT_ID --region=$GCP_REGION
gcloud beta compute addresses update kubeip-ip-0 --update-labels kubeip=$GKE_CLUSTER_NAME --region $GCP_REGION

# Deploy to Kubernetes cluster
sed -i "s/reserved/$GKE_CLUSTER_NAME/g" kubeip/deploy/kubeip-configmap.yaml
sed -i "s/default-pool/$KUBEIP_NODEPOOL/g" kubeip/deploy/kubeip-configmap.yaml
sed -i "s/pool-kubip/$KUBEIP_SELF_NODEPOOL/g" kubeip/deploy/kubeip-deployment.yaml

kubectl apply -f kubeip/deploy/.