#!/bin/bash


# Wait for kubectl deployment to be Running
#   Arguments:
#       $1 - Name of deployment
#   Example:
#       wait_for_deployment mongodb # this will wait for mongodb service to be Running
wait_for_deployment() {
    i=0
    wait_time=180
    while : ; do

        if [[ $(kubectl get pods | grep $1 | awk {'print $3'}) == "Running" ]]; then 
            echo "$1 pod is Running";
            break;
        elif [[ $((i>wait_time)) == 1 ]]; then
            echo "Failed to run $1.\n\tWaited for $wait_time seconds";
            exit;
        fi

        sleep 1;
        i=$((i+1));
        echo -en "\rWaiting for $1 pod to be Run. (Time elapsed: $i seconds)";
    done
}

# initialize secrets for mongodb user and pass
kubectl apply -f ./mongo-secret.yaml;

# create deployment of mongodb and service
kubectl apply -f ./mongo.yaml;

# checking if mongodb is ready
wait_for_deployment mongodb

kubectl apply -f ./mongo-configmap.yaml;

kubectl apply -f ./mongo-express.yaml;

wait_for_deployment mongo-express

minikube service mongo-express-service