# About
Steps to easily provision master and slave nodes for kubernetes!


### VirtualBox Configuration
In virtualbox, We have created 3 Ubuntu 20.04 Instances and connected them using Virtual NAT Network  

> Nat network is configurable in `VirtualBox > Preferences > Network > Add New NAT Network`  

In Virtual NAT network, Netowrk CIDR is `172.16.0.0/24` and support `DHCP`, `IPv6` are checked.  
All Instances are on same network


### ubuntu configuration  
Make sure you have installed `ansible` on master and `ssh server`, `net-tools` on all devices
```bash
# all devices
sudo apt-get update && sudo apt-get -y install net-tools openssh-server && sudo ufw allow ssh && sudo ufw -f enable;
```
```bash
# master
sudo apt-get -y install ansible
```



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
  
Initialize variables
```bash
TARGET=all
MASTER=masters
SLAVE=slaves
NODENAME=$(hostname -s);
IPADDR=$(ifconfig | grep inet | grep -vE -- "inet6|192.168|127.0.0.1|172.17" | awk {'print $2'});
PASS=RootPass
```
Provision Target devices
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
```bash
# Install helm
curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -;
sudo apt-get install apt-transport-https --yes;
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list;
sudo apt-get update;
sudo apt-get install helm;
```
Setup current device as ***master***
```bash
sudo kubeadm init --apiserver-advertise-address=$IPADDR  --apiserver-cert-extra-sans=$IPADDR  --pod-network-cidr=192.168.0.0/16 --node-name $NODENAME --ignore-preflight-errors Swap;

mkdir -p $HOME/.kube; sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config; sudo chown $(id -u):$(id -g) $HOME/.kube/config;

kubectl get po -n kube-system
```
Configur networking between *Nodes*
```bash
# install network for pods
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# update addresses for calico
kubectl set env daemonset/calico-node -n kube-system IP_AUTODETECTION_METHOD=interface=enp\*  
kubectl set env daemonset/calico-node -n kube-system FELIX_IGNORELOOSERPF=true  
```
**Optional**: Make master as one of nodes and allow pod deployment on master
```bash
# OPTIONAL: use master as node
# if we want to schedule apps from master
kubectl taint nodes --all node-role.kubernetes.io/master-
```
Connect ***nodes*** to ***master***
```bash
ansible -m shell -a "echo "$PASS" | sudo -S $(kubeadm token create --print-join-command) --ignore-preflight-errors=swap  --v=5" $SLAVE
```
Install `metrics service`
```bash
kubectl apply -f https://raw.githubusercontent.com/scriptcamp/kubeadm-scripts/main/manifests/metrics-server.yaml
```

## Quick installation in one command

slaves
```bash
IPADDR=$(ifconfig | grep inet | grep -vE -- "inet6|192.168|127.0.0.1|172.17" | awk {'print $2'});
# sudo arp -a | grep 172 | awk {'print $2'} | cut -c2-100 | sed 's/.$//' | sort | uniq | grep -v $IPADDR > netlist;
```