## Please see [run.sh](https://github.com/levankhelo/Kubernetes-Guide/blob/main/mysql/run.sh) for easy execution

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
    - password is `password`
 2. starting **mysql** `deployment`/`pod` and `service`
    - in [mongo.yaml](https://github.com/levankhelo/Kubernetes-Guide/blob/main/mysql/mysql.yaml), mongodb's both, deployment and service is described