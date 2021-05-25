# About
Steps to easily provision master and slave nodes for kubernetes!

### Table of contents
- Process
  - [Virtualbox Configuration](https://github.com/levankhelo/Kubernetes-Practical-Training/tree/main/clusters#ubuntu-configuration)
  - [Linux Configuration](https://github.com/levankhelo/Kubernetes-Practical-Training/tree/main/clusters#ubuntu-configuration)
  - [Ansible Configuration](https://github.com/levankhelo/Kubernetes-Practical-Training/tree/main/clusters#ansible-configuration)
  - [Linux Environment prerequisited](https://github.com/levankhelo/Kubernetes-Practical-Training/tree/main/clusters#environment-prerequisited) 
  - [Provision](https://github.com/levankhelo/Kubernetes-Practical-Training/tree/main/clusters#provisioning)
  - [Install HELM](https://github.com/levankhelo/Kubernetes-Practical-Training/tree/main/clusters#helm-installation)
  - [Administrator initialization](https://github.com/levankhelo/Kubernetes-Practical-Training/tree/main/clusters#adminmaster-initialization)
  - [Calico for networking](https://github.com/levankhelo/Kubernetes-Practical-Training/tree/main/clusters#calico-networking-setup)
  - Optional: [Tainting Master](https://github.com/levankhelo/Kubernetes-Practical-Training/tree/main/clusters#admin-node-tainting)
  - [Connectint to Nodes](https://github.com/levankhelo/Kubernetes-Practical-Training/tree/main/clusters#estabilish-connection-to-nodes)
  - [Setup Metrics service](https://github.com/levankhelo/Kubernetes-Practical-Training/tree/main/clusters#metric-service)
- [Results](https://github.com/levankhelo/Kubernetes-Practical-Training/tree/main/clusters#artifacts)

## VirtualBox Configuration
[Top](https://github.com/levankhelo/Kubernetes-Practical-Training/tree/main/clusters#table-of-contents)  
In virtualbox, We have created 3 Ubuntu 20.04 Instances and connected them using Virtual NAT Network  

> Nat network is configurable in `VirtualBox > Preferences > Network > Add New NAT Network`  

In Virtual NAT network, Netowrk CIDR is `172.16.0.0/24` and support `DHCP`, `IPv6` are checked.  
All Instances are on same network


## Ubuntu configuration  
[Top](https://github.com/levankhelo/Kubernetes-Practical-Training/tree/main/clusters#table-of-contents)    
Make sure you have installed `ansible` on master and `ssh server`, `net-tools` on all devices
```bash
# all devices
sudo apt-get update && sudo apt-get -y install net-tools openssh-server && sudo ufw allow ssh && sudo ufw -f enable;
```
```bash
# master
sudo apt-get -y install ansible
```


## Ansible Configuration
[Top](https://github.com/levankhelo/Kubernetes-Practical-Training/tree/main/clusters#table-of-contents)  
Configure `/etc/ansible/hosts` file with following format:
```conf
[masters]
master  ansible_ssh_host=172.16.0.5 ansible_ssh_user=master

[slaves]
slave1  ansible_ssh_host=172.16.0.6  ansible_ssh_user=slave1
slave2  ansible_ssh_host=172.16.0.4  ansible_ssh_user=slave2
```
> Please replace ip addresses based on your case of network configuration.
> Try running `ifconfig -a` on each device or `ifconfig | grep inet | grep -vE -- "inet6|192.168|127.0.0.1|172.17" | awk {'print $2'}` to get filtered output   
  
## Environment Prerequisited
Initialize variables
```bash
TARGET=all
MASTER=masters
SLAVE=slaves
NODENAME=$(hostname -s);
IPADDR=$(ifconfig | grep inet | grep -vE -- "inet6|192.168|127.0.0.1|172.17" | awk {'print $2'});
PASS=RootPass
```
# Provisioning
```bash
echo $PASS | sudo -S echo -e "\n----\t\e[32mProvisioning\e[39m\n";

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
ansible -m shell -a 'echo '$PASS' | sudo -S apt-get -y install docker-ce docker-ce-cli containerd.io' $TARGET;
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
ansible -m shell -a 'echo '$PASS' | sudo -S echo init; sudo ufw allow 179/tcp; sudo ufw allow 443/tcp; sudo ufw allow 2379:2380/tcp; sudo ufw allow 4789/tcp; sudo ufw allow 5473/tcp;sudo ufw allow 6443/tcp; sudo ufw allow 10250:10252/tcp; sudo ufw status verbose;' $MASTER

# sudo ufw allow 179/tcp; sudo ufw allow 4789/tcp; sudo ufw allow 5473/tcp; sudo ufw allow 443/tcp; sudo ufw allow 6443/tcp; sudo ufw allow 2379/tcp; sudo ufw allow 4149/tcp; sudo ufw allow 10250/tcp; sudo ufw allow 10255/tcp; sudo ufw allow 10256/tcp; sudo ufw allow 9099/tcp


# open ports on slaves
ansible -m shell -a 'echo '$PASS' | sudo -S echo init; sudo ufw allow 10250/tcp; sudo ufw allow 30000:32767/tcp; sudo ufw status verbose;' $SLAVE

# Calico ports for all
ansible -m shell -a 'echo '$PASS' | sudo -S echo init; sudo ufw allow 179/tcp; sudo ufw allow 4789/tcp; sudo ufw allow 5473/tcp; sudo ufw allow 443/tcp; sudo ufw allow 6443/tcp; sudo ufw allow 2379/tcp; sudo ufw allow 4149/tcp; sudo ufw allow 10250/tcp; sudo ufw allow 10255/tcp; sudo ufw allow 10256/tcp; sudo ufw allow 9099/tcp; sudo ufw status verbose;' $TARGET

ansible -m shell -a 'echo '$PASS' | sudo -S ufw --force enable && sudo ufw status verbose' $TARGET
```
# HELM installation
```bash
# Install helm
curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -;
sudo apt-get install apt-transport-https --yes;
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list;
sudo apt-get update;
sudo apt-get install helm;
```
# Admin/Master initialization
Setup current device as ***master***
```bash
sudo kubeadm init --apiserver-advertise-address=$IPADDR  --apiserver-cert-extra-sans=$IPADDR  --pod-network-cidr=192.168.0.0/16 --node-name $NODENAME --ignore-preflight-errors Swap;

mkdir -p $HOME/.kube; sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config; sudo chown $(id -u):$(id -g) $HOME/.kube/config;

kubectl get po -n kube-system
```
# Calico networking setup
Configur networking between *Nodes*
```bash
# install network for pods
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# update addresses for calico
kubectl set env daemonset/calico-node -n kube-system IP_AUTODETECTION_METHOD=interface=enp\*  
kubectl set env daemonset/calico-node -n kube-system FELIX_IGNORELOOSERPF=true  
```
### Admin node tainting
**Optional**: Make master as one of nodes and allow pod deployment on master
```bash
# OPTIONAL: use master as node
# if we want to schedule apps from master
kubectl taint nodes --all node-role.kubernetes.io/master-
```
## Estabilish connection to Nodes
Connect ***nodes*** to ***master***
```bash
ansible -m shell -a "echo "$PASS" | sudo -S $(kubeadm token create --print-join-command) --ignore-preflight-errors=swap  --v=5" $SLAVE
```
## Metric service
Install `metrics service`
```bash
kubectl apply -f https://raw.githubusercontent.com/scriptcamp/kubeadm-scripts/main/manifests/metrics-server.yaml
```

# Artifacts
[Top](https://github.com/levankhelo/Kubernetes-Practical-Training/tree/main/clusters#table-of-contents)  
## Command
```bash
echo && echo Nodes && echo ------------ && kubectl get nodes -A -o wide && echo && echo && echo Pods: kube-system && echo ------------ && kubectl get pods -n kube-system -A -o wide && echo && echo && echo Top && echo ------------ && kubectl top nodes
```
- `kubectl get nodes -A -o wide`
- `kubectl get pods -n kube-system -A -o wide`
- `kubectl top nodes`

## Result
```bash
Nodes
------------
NAME     STATUS   ROLES                  AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION     CONTAINER-RUNTIME
master   Ready    control-plane,master   15h   v1.21.1   172.16.0.5    <none>        Ubuntu 20.04.2 LTS   5.8.0-50-generic   docker://20.10.6
slave1   Ready    <none>                 15h   v1.21.1   172.16.0.6    <none>        Ubuntu 20.04.2 LTS   5.8.0-50-generic   docker://20.10.6
slave2   Ready    <none>                 15h   v1.21.1   172.16.0.4    <none>        Ubuntu 20.04.2 LTS   5.8.0-50-generic   docker://20.10.6


Pods: kube-system
------------
NAMESPACE     NAME                                       READY   STATUS    RESTARTS   AGE   IP                NODE     NOMINATED NODE   READINESS GATES
kube-system   calico-kube-controllers-78d6f96c7b-6nwvf   1/1     Running   1          15h   192.168.219.69    master   <none>           <none>
kube-system   calico-node-4q88z                          1/1     Running   1          15h   172.16.0.6        slave1   <none>           <none>
kube-system   calico-node-kg5pz                          1/1     Running   1          15h   172.16.0.5        master   <none>           <none>
kube-system   calico-node-mqxmt                          1/1     Running   1          15h   172.16.0.4        slave2   <none>           <none>
kube-system   coredns-558bd4d5db-468bm                   1/1     Running   1          15h   192.168.219.68    master   <none>           <none>
kube-system   coredns-558bd4d5db-5h228                   1/1     Running   1          15h   192.168.219.70    master   <none>           <none>
kube-system   etcd-master                                1/1     Running   1          15h   172.16.0.5        master   <none>           <none>
kube-system   kube-apiserver-master                      1/1     Running   1          15h   172.16.0.5        master   <none>           <none>
kube-system   kube-controller-manager-master             1/1     Running   1          15h   172.16.0.5        master   <none>           <none>
kube-system   kube-proxy-kpblt                           1/1     Running   1          15h   172.16.0.4        slave2   <none>           <none>
kube-system   kube-proxy-vspxd                           1/1     Running   1          15h   172.16.0.6        slave1   <none>           <none>
kube-system   kube-proxy-wnc4c                           1/1     Running   1          15h   172.16.0.5        master   <none>           <none>
kube-system   kube-scheduler-master                      1/1     Running   1          15h   172.16.0.5        master   <none>           <none>
kube-system   metrics-server-6cdc946bc4-xp69w            1/1     Running   0          46m   192.168.140.193   slave1   <none>           <none>


Top
------------
W0525 10:52:03.553732  146413 top_node.go:119] Using json format to get metrics. Next release will switch to protocol-buffers, switch early by passing --use-protocol-buffers flag
NAME     CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%   
master   723m         36%    2110Mi          72%       
slave1   89m          8%     1062Mi          73%       
slave2   77m          7%     1114Mi          77%  
```