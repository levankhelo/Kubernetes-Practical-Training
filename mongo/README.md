## Please see [run.sh](https://github.com/levankhelo/Kubernetes-Guide/blob/main/mongo/run.sh) for easy execution

### If you are using minikube and this is only thing installed, you can run following commands to clean up your minikube insance
```bash
kubectl delete --all deployments;
kubectl delete --all services;
kubectl delete --all secrets;
kubectl delete --all configmaps;
```
## general actions
 1. starting secrets
    - mongodb admin's `base64`ed `username` and `password` is stored
    - username and password, are both `root`
 2. starting mongodb `deployment`/`pod` and `service`
    - in [mongo.yaml](https://github.com/levankhelo/Kubernetes-Guide/blob/main/mongo/mongo.yaml), mongodb's both, deployment and service is described
 3. starting configmap to connect mongodb and express
    - in configmap, database url is described, that is refered from express, later
 4. starting `mongo-express` `deployment`/`pod` and `service`
    - in [mongo-express.yaml](https://github.com/levankhelo/Kubernetes-Guide/blob/main/mongo/mongo-express.yaml), mongo-express's both, deployment and service is described  
    - MongoExpress is `express` based, simple web application for mongo-db
 5. starting `mongo-express-service` to map external ip of `mongo-expreess` and make it publicaly accessible