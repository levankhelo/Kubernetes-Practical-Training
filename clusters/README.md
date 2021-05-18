# About
Steps to easily provision master and slave nodes for kubernetes!

# Actions
Here are actions for slave and master nodes!   
Just copy and paste them in terminal 


# Ansible configuration - Optional
For ansible, we have used same setup that we created in [chapter-6/ansible](https://github.com/levankhelo/chapter-6#step-1-installing-ansible) guide
Our updated hosts file looks like this.
```conf
[master]
master1 ansible_ssh_host=127.0.0.1      ansible_ssh_user=master
[slaves]
slave1 ansible_ssh_host=192.168.56.102 ansible_ssh_user=slave
slave2 ansible_ssh_host=192.168.56.104 ansible_ssh_user=slave
```
## Slave / Node
Acrtions required for
### Manual
Install requirements manually on each device
```bash

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
```

### Ansible
For ansible, we have used same setup that we created in [chapter-6/ansible](https://github.com/levankhelo/chapter-6#step-1-installing-ansible) guide


```bash

PASS=password
TARGET=slaves

# General Configuration
ansible -m shell -a 'echo '$PASS' | sudo swapoff -a' $TARGET;
ansible -m shell -a "echo "$PASS" | sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab" $TARGET;

# Installing Runtime (Docker)
    # install dependencies
    ansible -m shell -a 'echo '$PASS' | sudo -S apt-get -y install apt-transport-https ca-certificates curl gnupg lsb-release;' $TARGET;
    # add repo
    ansible -m shell -a 'echo '$PASS' | sudo -S echo init; curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --yes --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg' $TARGET;
    ansible -m shell -a 'echo '$PASS' | sudo -S echo init; echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null' $TARGET;
    # install docker
    ansible -m shell -a 'echo '$PASS' | sudo -S apt-get update && sudo apt-get -y install docker-ce docker-ce-cli containerd.io' $TARGET;
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
```
> Note: Make sure to replace `password` with *password* of *slaves*, to execute commands as *root* user on nodes


## Master
```bash
sudo apt-get update;
sudo apt-get install -y apt-transport-https ca-certificates curl;
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg;
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list;
sudo apt-get update;
sudo apt-get install -y kubelet kubeadm kubectl;
sudo apt-mark hold kubelet kubeadm kubectl;
```