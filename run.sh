#!/bin/bash -xe

AWS_PROFILE_NAME="jobbatical";

if [ $# -lt 4 -o $# -gt 5 ];
then
    echo -ne "Invalid number of arguments.\n";
    echo -ne "Usage: $0 <AWS_ACCESS_KEY> <AWS_SECRET_KEY>  <PATH_TO_SSH_PUBLIC_KEY> <PATH_TO_SSH_PVT_KEY> [ AWS_PROFILE_NAME (default: jobbatical) ]"
else
    if [ ! -z $5 ];
    then
        AWS_PROFILE_NAME=$5;
    fi

    $(which aws) configure set aws_access_key_id "$1" --profile "$AWS_PROFILE_NAME"
    $(which aws) configure set aws_secret_access_key "$2" --profile "$AWS_PROFILE_NAME"

    terraform init
    terraform apply -var "access_key=$1" -var "secret_key=$2" -var "deployer_key_file=$3" -var "deployer_pvt_key_file=$4" -var "profilename=$AWS_PROFILE_NAME";

    mkdir -p ./.kube && cp files/jobbatical-kubeconfig ./.kube/
    sed -i '1,2d' $(pwd)/.kube/jobbatical-kubeconfig
    KUBECONFIG=$(pwd)"/.kube/jobbatical-kubeconfig" kubectl apply -f files/config-map-aws-auth.yaml
fi