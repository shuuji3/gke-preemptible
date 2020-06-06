#!/usr/bin/env bash
gcloud compute firewall-rules create gke-preemptible-ingress \
  --allow tcp:80,tcp:443,tcp:8080
