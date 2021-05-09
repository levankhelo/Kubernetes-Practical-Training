<p style="font-size:24px"> Please see <a href="https://github.com/levankhelo/Kubernetes-Guide/blob/main/mongo/actions.sh"> <span style="font-size:32px"> actions.sh</span>  </a> for automated execution
</h1>

<div style="width: 100%; border: 3px solid black; margin-bottom: 25px;">
</div>

# general actions
 1. starting secrets
    - mongodb admin's `hash64`ed `username` and `password` is stored
 2. starting mongodb `deployment`/`pod` and `service`
    - in [mongo.yaml](https://github.com/levankhelo/Kubernetes-Guide/blob/main/mongo/mongo.yaml), mongodb's both, deployment and service is described
 3. starting configmap to connect mongodb and express
    - in configmap, database url is described, that is refered from express, later
 4. starting `mongo-express` `deployment`/`pod` and `service`
    - in [mongo-express.yaml](https://github.com/levankhelo/Kubernetes-Guide/blob/main/mongo/mongo-express.yaml), mongo-express's both, deployment and service is described  
    - MongoExpress is `express` based, simple web application for mongo-db
 5. starting `mongo-express-service` to map external ip of `mongo-expreess` and make it publicaly accessible