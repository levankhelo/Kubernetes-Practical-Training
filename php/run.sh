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
        echo -en "\rWaiting for $1 pod to be up and Running. (Time elapsed: $i seconds)";
    done
}

if [[ $1 == "--delete" ]] || [[ $1 == "-d" ]]; then
    kubectl delete --all deployments;
    kubectl delete --all services;
    kubectl delete --all secrets;
    kubectl delete --all configmaps;
    exit;
fi

# initialize secrets for mysql password for root user
kubectl apply -f mysql-secret.yaml

# create deployment of mysql and service
kubectl apply -f mysql.yaml

wait_for_deployment mysql

kubectl apply -f configmap.yaml

kubectl apply -f phpmyadmin-configmap.yaml

kubectl apply -f phpmyadmin.yaml

wait_for_deployment phpmyadmin

minikube service phpmyadmin-service