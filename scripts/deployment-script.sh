#!/bin/bash -xe

source ~/.bashrc

cat << EOF > node-todo-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: node-todo
  labels:
    app: node-todo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: node-todo
  template:
    metadata:
      labels:
        app: node-todo
    spec:
      containers:
      - name: node-todo
        image: IMAGEANDTAG
        ports:
        - containerPort: 8080

EOF

export DOCKER_REGISTRY=$(cat ~/dockerregistry)

imageandtag=$DOCKER_REGISTRY:$IMAGETAG

sed -i "s#IMAGEANDTAG#$DOCKER_REGISTRY:$IMAGETAG#" node-todo-deployment.yaml

cat node-todo-deployment.yaml

kubectl delete deployments node-todo -n jobbatical || true

kubectl apply -f node-todo-deployment.yaml -n jobbatical

APP_ENDPOINT=$(kubectl get svc node-todo -n jobbatical -o json | jq '.status.loadBalancer.ingress[0].hostname')

echo  "You may access the application via $APP_ENDPOINT"
