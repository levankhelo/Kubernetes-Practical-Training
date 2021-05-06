# Kubernetes-Guide

### Table of Contents:
  1. Installation  
    1. Minikube  
    2. Kubectl
 1. Command Guide  
    - Create `Pod` - `kubectl create deployment POD-NAME --image=IMAGE`
    - Edit `Pod` - `kubectl edit deployment POD-NAME`
    - 

## Course on [YouTube](https://www.youtube.com/watch?v=X48VuDVv0do)


## General

`pod`  
> -Description: Minimal element of kubernetes. This is instance of Container like ngnix or mongodb    

to create `pod` we are using `deploy` command
```bash
kubectl create deployment ngnix-depl --image=nginx
```
> Format: `kubectl create deployment NAME --image=IMAGE`  

<br><br>

Creating `pod`/`deployment`, replicaset is automatically created.
> by creating `nginx-depl` we will have `pod` named `nginx-depl-1A2B3C-9Z8Y` where `1A2B3C` is `replicaset` id and `9Z8Y` is `pod` id
  
<br><br>
`replicaset`  
> Description: After creating pod, it automatically creates `replicaset`, so we will have TYPE of pod, that we can reuse later
    
<br><br>  

```bash
kubectl edit deployment POD-NAME
```

Editing Deployment Configuration for `POD-NAME` automatically changes pod (*downloads, deploys*) based on new configuration
> Note: edit opens in `vim`, so be ready! use `ESC` following with `i` to enter **INSERT** mode and change something. Save file using `ESC` following `:w!` and to exit vim use `ESC` following `:q!`


<br><br>
```bash
kubectl logs POD-NAME
```
Displays logs of selected `pod`

<br><br>
```bash
kubectl describe pod POD-NAME
```
get additional description of pod
> you can use it with other things like `service`, `replicaset` and so on