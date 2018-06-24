apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: mongodb
  labels:
    app: mongodb
    tier: backend
spec:
  replicas: 1
  selector:
    matchLabels:
      tier: backend
  template:
    metadata:
      labels:
        app: mongodb
        tier: backend
    spec:
      containers:
      - name: mongodb
        image: mongo:latest
        resources:
          requests:
            cpu: 200m
            memory: 200Mi
        env:
        - name: GET_HOSTS_FROM
          value: dns
        ports:
        - containerPort: 27017