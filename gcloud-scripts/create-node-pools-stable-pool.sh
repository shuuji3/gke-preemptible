#!/usr/bin/env bash

CLUSTER_NAME=preemptible
ZONE=asia-east1

gcloud container node-pools create stable-pool \
  --cluster ${CLUSTER_NAME} \
  --num-nodes 1 \
  --machine-type g1-small \
  --disk-size 10 \
  --zone ${ZONE} \
  --node-locations=${ZONE}-a
