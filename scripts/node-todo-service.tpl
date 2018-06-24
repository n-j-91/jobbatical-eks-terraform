kind: Service
apiVersion: v1
metadata:
  name: node-todo
spec:
  selector:
    app: node-todo
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
  type: LoadBalancer