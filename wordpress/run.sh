#!/bin/bash



wait_for_deployment() {
    i=0
    wait_time=180
    while : ; do

        if [[ $(kubectl get pods | grep $1 | awk {'print $3'}) == "Running" ]]; then 
            echo "  $1 pod is Running";
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


if ! command -v helm; then
	
	echo Installing helm

	if [[ $(uname -s) == "Linux" ]]; then
		sudo apt-get update && sudo apt-get install -y helm;
	else
		brew install helm;
	fi

	if ! command -v helm; then
		echo Failed to install helm...;
		exit;
	else
		echo Successfully Installed helm;
	fi

fi

helm install wordpress bitnami/wordpress --values=values.yaml

wait_for_deployment wordpress-mariadb
wait_for_deployment $(kubectl get pods | grep -v mariadb | grep wordpress | HEAD -n 1 | awk {'print $1'} )


minikube service wordpress

echo ""
echo "-----------------------------------------------------------------------------------------"
echo "|||||||| make sure you replace http with https in your browser, when it opens up ||||||||"
echo "-----------------------------------------------------------------------------------------"
echo ""

