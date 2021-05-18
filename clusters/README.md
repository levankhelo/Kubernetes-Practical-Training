# About
Steps to easily provision master and slave nodes for kubernetes!

### Table of contents
1. [Configuration](https://github.com/levankhelo/Kubernetes-Practical-Training/tree/main/clusters#ansible-configuration---master---optional)  
    1. [Ansible](https://github.com/levankhelo/Kubernetes-Practical-Training/tree/main/clusters#changes)  
          - [hosts](https://github.com/levankhelo/Kubernetes-Practical-Training/tree/main/clusters#hosts-configuration-file)  
    2. [VirtualBox](https://github.com/levankhelo/Kubernetes-Practical-Training/tree/main/clusters#virtualbox)  
2. [Dependencies](https://github.com/levankhelo/Kubernetes-Practical-Training/tree/main/clusters#installing-dependencies)  
    1. [Slave](https://github.com/levankhelo/Kubernetes-Practical-Training/tree/main/clusters#manual---slave)  
          - [Manual](https://github.com/levankhelo/Kubernetes-Practical-Training/tree/main/clusters#manual---slave)  - on slave node  
          - [Ansible](https://github.com/levankhelo/Kubernetes-Practical-Training/tree/main/clusters#ansible) - from master node  
    2. [Master](https://github.com/levankhelo/Kubernetes-Practical-Training/tree/main/clusters#dependencies---master)  
    3. [Initialization of Master](https://github.com/levankhelo/Kubernetes-Practical-Training/tree/main/clusters#initialize-adminmaster-node---master)  
3. [Connecting nodes](https://github.com/levankhelo/Kubernetes-Practical-Training/tree/main/clusters#connecting-nodes)  
    - [Manual](https://github.com/levankhelo/Kubernetes-Practical-Training/tree/main/clusters#manual)  - on slave node  
    - [Ansible](https://github.com/levankhelo/Kubernetes-Practical-Training/tree/main/clusters#ansible-1) - from master node  



# Ansible Configuration - Master - Optional
For ansible, we have used same setup that we created in [chapter-6/ansible](https://github.com/levankhelo/chapter-6#step-1-installing-ansible) guide
## Changes
### hosts configuration file
[Back to top](https://github.com/levankhelo/Kubernetes-Practical-Training/tree/main/clusters#table-of-contents)  
Our updated hosts file looks like this.
```conf
[master]
master1 ansible_ssh_host=127.0.0.1      ansible_ssh_user=master
[slaves]
slave1 ansible_ssh_host=192.168.56.102 ansible_ssh_user=slave
slave2 ansible_ssh_host=192.168.56.104 ansible_ssh_user=slave
```

### virtualbox
[Back to top](https://github.com/levankhelo/Kubernetes-Practical-Training/tree/main/clusters#table-of-contents)  
In virtualboxs master configuration, we increased processing power, CPU from 1 to 2.
# Installing Dependencies

### Manual - Nodes
[Back to top](https://github.com/levankhelo/Kubernetes-Practical-Training/tree/main/clusters#table-of-contents)  

Provisioning all Nodes, Especially Master

```bash

sudo apt-get update;

# Installing Container
sudo apt-get -y install apt-transport-https ca-certificates curl gnupg lsb-release;
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg;
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null;
sudo apt-get update && sudo apt-get -y install docker-ce docker-ce-cli containerd.io;

# General Configuration
sudo swapoff -a && sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab;
```
```bash
# Installing Docker
sudo apt-get -y install apt-transport-https ca-certificates curl gnupg lsb-release;
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --yes --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null;
sudo apt-get update && sudo apt-get -y install docker-ce docker-ce-cli containerd.io;

sudo mkdir /etc/docker
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

sudo systemctl enable docker; sudo systemctl daemon-reload; sudo systemctl restart docker;

# Installing kubee
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -;
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list 
deb https://apt.kubernetes.io/ kubernetes-xenial main 
EOF

# installing kube
sudo apt-get update && sudo apt-get install -y kubelet kubeadm kubectl && sudo apt-mark hold kubelet kubeadm kubectl
```

### Ansible
[Back to top](https://github.com/levankhelo/Kubernetes-Practical-Training/tree/main/clusters#table-of-contents)  

This script is used for slave device provisioning from master device with ansible

```bash
PASS=password
TARGET=slaves
```
```bash
# General Configuration
ansible -m shell -a "echo "$PASS" | sudo -S swapoff -a; sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab" $TARGET;

# Installing Runtime (Docker)
# install dependencies
ansible -m shell -a 'echo '$PASS' | sudo -S apt-get -y install apt-transport-https ca-certificates curl gnupg lsb-release;' $TARGET;
# add repo
ansible -m shell -a 'echo '$PASS' | sudo -S echo init; curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --yes --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg' $TARGET;
ansible -m shell -a 'echo '$PASS' | sudo -S echo init; echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null' $TARGET;
# install docker
ansible -m shell -a 'echo '$PASS' | sudo -S apt-get update' $TARGET;
ansible -m shell -a 'echo '$PASS' | sudo -S apt-get -y install docker-ce' $TARGET;
ansible -m shell -a 'echo '$PASS' | sudo -S docker-ce-cli' $TARGET;
ansible -m shell -a 'echo '$PASS' | sudo -S containerd.io' $TARGET;
# update services
ansible -m shell -a 'echo '$PASS' | sudo -S echo init; cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF' $TARGET;
ansible -m shell -a 'echo '$PASS' | sudo -S echo init; sudo systemctl enable docker; sudo systemctl daemon-reload; sudo systemctl restart docker' $TARGET;

ansible -m shell -a 'echo '$PASS' | sudo -S echo init; sudo systemctl start ufw; sudo ufw enable; sudo ufw allow 10250/tcp; sudo ufw allow 30000:32767/tcp;' $TARGET

# Installing kube
# upating repo
ansible -m shell -a 'echo '$PASS' | sudo -S echo init; curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - ' $TARGET;
ansible -m shell -a 'echo '$PASS' | sudo -S echo init; cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list 
deb https://apt.kubernetes.io/ kubernetes-xenial main 
EOF' $TARGET;
ansible -m shell -a 'echo '$PASS' | sudo -S apt-get update' $TARGET;
# installing kube
ansible -m shell -a 'echo '$PASS' | sudo -S apt-get install -y kubelet kubeadm kubectl' $TARGET;
# disable updates of kube
ansible -m shell -a 'echo '$PASS' | sudo -S apt-mark hold kubelet kubeadm kubectl' $TARGET;
```
> Note: Make sure to replace `password` with *password* of *slaves*, to execute commands as *root* user on nodes



### Dependencies - Master
[Back to top](https://github.com/levankhelo/Kubernetes-Practical-Training/tree/main/clusters#table-of-contents)  

```bash
# Installing kube
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -;
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list 
deb https://apt.kubernetes.io/ kubernetes-xenial main 
EOF
sudo apt-get update; sudo apt-get install -y kubelet kubeadm kubectl; sudo apt-mark hold kubelet kubeadm kubectl
```

### Initialize admin/master node - Master
[Back to top](https://github.com/levankhelo/Kubernetes-Practical-Training/tree/main/clusters#table-of-contents)  
```bash
# ifconfig -a # find ip address that should look like: inet 10.0.0.10 # you can try manually
IPADDR="$(ifconfig -a | grep -vE -- "inet6|172.|192.|127." | grep -E -- "inet" | awk {'print $2'})"
NODENAME=$(hostname -s);
sudo kubeadm init --apiserver-advertise-address=$IPADDR  --apiserver-cert-extra-sans=$IPADDR  --pod-network-cidr=192.168.0.0/16 --node-name $NODENAME --ignore-preflight-errors Swap;

mkdir -p $HOME/.kube; sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config; sudo chown $(id -u):$(id -g) $HOME/.kube/config;

kubectl get po -n kube-system

# if we want to schedule apps from master
kubectl taint nodes --all node-role.kubernetes.io/master-
```

# Connecting nodes

### Manual
[Back to top](https://github.com/levankhelo/Kubernetes-Practical-Training/tree/main/clusters#table-of-contents)  
On Master: 
```bash
    kubeadm token create --print-join-command
```
Capture this command's output and execute them on slave devices

### Ansible
[Back to top](https://github.com/levankhelo/Kubernetes-Practical-Training/tree/main/clusters#table-of-contents)  
On master
```bash
PASS=password
TARGET=slaves
```
```bash
ansible -m shell -a "echo "$PASS" | sudo -s $(kubeadm token create --print-join-command) --ignore-preflight-errors=swap " $TARGET
```





# Summary
All commands together for master!

Make sure you have configured `/etc/ansible/hosts` file with following format:
```conf
[masters]
master1 ansible_ssh_host=127.0.0.1     ansible_ssh_user=master

[slaves]
slave1 ansible_ssh_host=192.168.56.102 ansible_ssh_user=slave
slave2 ansible_ssh_host=192.168.56.104 ansible_ssh_user=slave

[target]
masters
slaves

```
```bash
TARGET=target
MASTER=master
SLAVE=slaves
PASS=password
```

```bash
# General Configuration
ansible -m shell -a "echo "$PASS" | sudo -S swapoff -a; sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab" $TARGET;

# Installing Runtime (Docker)
# install dependencies
ansible -m shell -a 'echo '$PASS' | sudo -S apt-get -y install apt-transport-https ca-certificates curl gnupg lsb-release;' $TARGET;
# add repo
ansible -m shell -a 'echo '$PASS' | sudo -S echo init; curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --yes --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg' $TARGET;
ansible -m shell -a 'echo '$PASS' | sudo -S echo init; echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null' $TARGET;
# install docker
ansible -m shell -a 'echo '$PASS' | sudo -S apt-get update' $TARGET;
ansible -m shell -a 'echo '$PASS' | sudo -S apt-get -y install docker-ce' $TARGET;
ansible -m shell -a 'echo '$PASS' | sudo -S docker-ce-cli' $TARGET;
ansible -m shell -a 'echo '$PASS' | sudo -S containerd.io' $TARGET;
# update services
ansible -m shell -a 'echo '$PASS' | sudo -S echo init; cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF' $TARGET;
ansible -m shell -a 'echo '$PASS' | sudo -S echo init; sudo systemctl enable docker; sudo systemctl daemon-reload; sudo systemctl restart docker' $TARGET;

# Installing kube
# upating repo
ansible -m shell -a 'echo '$PASS' | sudo -S echo init; curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - ' $TARGET;
ansible -m shell -a 'echo '$PASS' | sudo -S echo init; cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list 
deb https://apt.kubernetes.io/ kubernetes-xenial main 
EOF' $TARGET;
ansible -m shell -a 'echo '$PASS' | sudo -S apt-get update' $TARGET;
# installing kube
ansible -m shell -a 'echo '$PASS' | sudo -S apt-get install -y kubelet kubeadm kubectl' $TARGET;
# disable updates of kube
ansible -m shell -a 'echo '$PASS' | sudo -S apt-mark hold kubelet kubeadm kubectl' $TARGET;


# open ports on master
ansible -m shell -a 'echo '$PASS' | sudo -S echo init; sudo systemctl start ufw; sudo ufw enable; sudo ufw allow 6443/tcp; sudo ufw allow 2379:2380/tcp; sudo ufw allow 10250:10252/tcp;' $MASTER

# open ports on slaves
ansible -m shell -a 'echo '$PASS' | sudo -S echo init; sudo systemctl start ufw; sudo ufw enable; sudo ufw allow 10250/tcp; sudo ufw allow 30000:32767/tcp;' $SLAVE

IPADDR="$(ifconfig -a | grep -vE -- "inet6|172.|192.|127." | grep -E -- "inet" | awk {'print $2'})"
NODENAME=$(hostname -s);
sudo kubeadm init --apiserver-advertise-address=$IPADDR  --apiserver-cert-extra-sans=$IPADDR  --pod-network-cidr=192.168.0.0/16 --node-name $NODENAME --ignore-preflight-errors Swap;

mkdir -p $HOME/.kube; sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config; sudo chown $(id -u):$(id -g) $HOME/.kube/config;

kubectl get po -n kube-system

# if we want to schedule apps from master
kubectl taint nodes --all node-role.kubernetes.io/master-


ansible -m shell -a "echo "$PASS" | sudo -s $(kubeadm token create --print-join-command) --ignore-preflight-errors=swap " $SLAVE
```