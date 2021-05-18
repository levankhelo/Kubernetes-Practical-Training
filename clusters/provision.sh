#!/bin/bash

sudo apt-get update;




# Installing Container
sudo apt-get -y install apt-transport-https ca-certificates curl gnupg lsb-release;
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg;
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null;
sudo apt-get update && sudo apt-get -y install docker-ce docker-ce-cli containerd.io;



# General Configuration
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Installing Container
    # install dependencies
    sudo apt-get -y install apt-transport-https ca-certificates curl gnupg lsb-release;
    # add repo
    sudo echo init; curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --yes --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    sudo echo init; echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    # install docker
    sudo apt-get update && sudo apt-get -y install docker-ce docker-ce-cli containerd.io
    # update services
    cat <<EOF | sudo tee /etc/docker/daemon.json
{
"exec-opts": ["native.cgroupdriver=systemd"],
"log-driver": "json-file",
"log-opts": {
    "max-size": "100m"
},
"storage-driver": "overlay2"
}
EOF;
    sudo systemctl enable docker; sudo systemctl daemon-reload; sudo systemctl restart docker

# Installing kube
    # upating repo
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
    cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list 
deb https://apt.kubernetes.io/ kubernetes-xenial main 
EOF
    sudo apt-get update
    # installing kube
    sudo apt-get install -y kubelet kubeadm kubectl
    # disable updates of kube
    sudo apt-mark hold kubelet kubeadm kubectl
    