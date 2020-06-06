#!/usr/bin/env bash

CLUSTER_NAME=preemptible
ZONE=asia-east1

gcloud container clusters create ${CLUSTER_NAME} \
  --preemptible \
  --machine-type=n1-standard-1 \
  --num-nodes=1 \
  --disk-size=10 \
  --zone $ZONE \
  --enable-autorepair
