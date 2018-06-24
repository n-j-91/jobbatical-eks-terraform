#!/bin/bash -xe

AWS_PROFILE_NAME="jobbatical";

if [ $# -lt 2 -o $# -gt 3 ];
then
    echo -ne "Invalid number of arguments.\n";
    echo -ne "Usage: $0 <AWS_ACCESS_KEY> <AWS_SECRET_KEY> [ AWS_PROFILE_NAME (default: jobbatical) ]"
else
    if [ ! -z $3 ];
    then
        AWS_PROFILE_NAME=$3;
    fi

    $(which aws) configure set aws_access_key_id "$1" --profile "$AWS_PROFILE_NAME"
    $(which aws) configure set aws_secret_access_key "$2" --profile "$AWS_PROFILE_NAME"

    terraform init
    terraform apply -var "access_key=$1" -var "secret_key=$2" -var "profilename=$AWS_PROFILE_NAME";

    terraform output jobbatical-kubeconfig > files/jobbatical-kubeconfig
    terraform output config-map-aws-auth > files/config-map-aws-auth.yaml

    mkdir -p ./.kube && mv files/jobbatical-kubeconfig ./.kube/
    KUBECONFIG=$(pwd)"/.kube/jobbatical-kubeconfig" kubectl apply -f files/config-map-aws-auth.yaml
fi