Please see actions.sh

# general actions
 1. starting secrets
    - mongodb admin's `hash64`ed `username` and `password` is stored
 2. starting mongodb `deployment`/`pod` and `service`
    - in [mongo.yaml](), mongodb's both, deployment and service is described
 3. starting configmap to connect mongodb and express
    - in configmap, database url is described, that is refered from express, later
 4. starting `mongo-express` `deployment`/`pod` and `service`
    - in [mongo-express.yaml](), mongo-express's both, deployment and service is described  
    - MongoExpress is `express` based, simple web application for mongo-db
 5. starting `mongo-express-service` to map external ip of `mongo-expreess` and make it publicaly accessible