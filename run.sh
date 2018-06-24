#!/bin/bash -xe

AWS_PROFILE_NAME="jobbatical";

if [ $# -lt 3 -o $# -gt 4 ];
then
    echo -ne "Invalid number of arguments.\n";
    echo -ne "Usage: $0 <AWS_ACCESS_KEY> <AWS_SECRET_KEY>  <PATH_TO_SSH_PUBLIC_KEY> [ AWS_PROFILE_NAME (default: jobbatical) ]"
else
    if [ ! -z $4 ];
    then
        AWS_PROFILE_NAME=$4;
    fi

    $(which aws) configure set aws_access_key_id "$1" --profile "$AWS_PROFILE_NAME"
    $(which aws) configure set aws_secret_access_key "$2" --profile "$AWS_PROFILE_NAME"

    terraform init
    terraform apply -var "access_key=$1" -var "secret_key=$2" -var "deployer_key_file=$3" -var "profilename=$AWS_PROFILE_NAME";

    mkdir -p ./.kube && cp files/jobbatical-kubeconfig ./.kube/
    KUBECONFIG=$(pwd)"/.kube/jobbatical-kubeconfig" kubectl apply -f files/config-map-aws-auth.yaml
fi