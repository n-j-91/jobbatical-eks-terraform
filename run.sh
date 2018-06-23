#!/bin/bash

terraform init
terraform apply -auto-approve

terraform output jobbatical-kubeconfig > jobbatical-kubeconfig
terraform output config-map-aws-auth > config-map-aws-auth.yaml

mkdir -p ./.kube && mv jobbatical-kubeconfig ./.kube/
export KUBECONFIG=$KUBECONFIG:$(pwd)"/.kube/jobbatical-kubeconfig"
kubectl apply -f config-map-aws-auth.yaml