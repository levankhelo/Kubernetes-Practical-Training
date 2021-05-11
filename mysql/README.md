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
    - mongodb admin's `hash`ed (`sha-1`) `username` and `password` is stored
    - root_password is `root` and so is default username and password
 2. starting **mysql** `deployment`/`pod` and `service`
    - in [mysql.yaml](https://github.com/levankhelo/Kubernetes-Guide/blob/main/mysql/mysql.yaml), mysql's both, deployment and service is described