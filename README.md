# Redis Demo App
Some sample code for learning Ruby

This Ruby app reads and writes to Redis through simple HTTP server.

### Build the Docker image
```
make build
```

### Start minikube

```
minikube start
```

### Deploy the ruby app and redis

```
k apply -f redis-deployment.yaml
k apply -f app-deployment.yaml
```

### Forward the port of ruby app

```
kubectl port-forward <port name> 3000:8080
```

### Visit the ruby app through port 3000

Using the following URLs to visit the ruby app:
* http://localhost:3000
* http://localhost:3000/GET?some_key
* http://localhost:3000/SET?some_key=100
