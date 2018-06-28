#!/bin/bash -xe

whoami
source ~/.bashrc

pwd
ls -al
mongoSvcIP=$(kubectl get svc mongodb -n jobbatical -o json | jq '.spec.clusterIP')


sed -i "s/node:nodeuser@mongo.onmodulus.net/${mongoSvcIP:1:-1}/" config/database.js

cat config/database.js

sed -i 's/localUrl/remoteUrl/' server.js

cat server.js

npm install

echo "FROM node:latest" > Dockerfile
echo "ADD . /app/" >> Dockerfile
echo "EXPOSE 8080" >> Dockerfile
echo "ENTRYPOINT [\"node\",\"/app/server.js\"]" >> Dockerfile

$(aws ecr get-login --no-include-email --region $REGION --profile $PROFILE)

export DOCKER_REGISTRY=$(cat ~/dockerregistry)

docker build -t jobbatical-ecr .

docker tag jobbatical-ecr:$TAG $DOCKER_REGISTRY

docker push $DOCKER_REGISTRY:$TAG

exit 0