apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: node-todo
  labels:
    app: node-todo
    tier: frontend
spec:
  replicas: 2
  selector:
    matchLabels:
      tier: frontend
  template:
    metadata:
      labels:
        app: node-todo
        tier: frontend
    spec:
      containers:
      - name: node-todo
        image: ${image_repo}:latest
        resources:
          requests:
            cpu: 200m
            memory: 200Mi
        env:
        - name: GET_HOSTS_FROM
          value: dns
        ports:
        - containerPort: 8080