# Kubernetes 101

## Erzeugen des Clusters

Beispielhaft 5 Nodes Ubuntu-22.04

Auf allen Nodes
```
apt update
apt install git

useradd -m k8s
passwd k8s

sudo update-alternatives --config editor
3

visudo
k8s ALL=(ALL) NOPASSWD:ALL

# Nur zu Schulungszwecken. Bitte alle benötigten Ports in Produktiven Umgebungen öffnen!
ufw disable 
```


Auf einer zusätzlichen DevOps Node
```
apt update
apt install python3
apt install python3-pip
apt install virtualenv

git clone https://github.com/kubernetes-sigs/kubespray.git
cd kubespray
git checkout tags/v2.24.1

source venv/bin/activate
pip3 install -r requirements.txt

cp -rfp inventory/sample inventory/mycluster

ssh-copyid ALLE_IPS

declare -a IPS=( 116.203.148.77 49.13.206.146 195.201.226.208 5.75.189.50 116.203.122.42 )
CONFIG_FILE=inventory/mycluster/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}

ansible-playbook -i inventory/mycluster/hosts.yaml  --become --user=k8s cluster.yml
```


## Beschreiben der Ressourcen

- Pod
- ReplicaSet
- Deployments
- Services
- Batch Jobs
- Cron Jobs
- Ingess
- Persistent Volume
- Persisten Volume Claim



## Nodes

```
k get no
k get no -o wide
```



## Architektur

```
k -n kube-system get po
```


## Namespaces

```
k create ns nginx
k run nginx --image nginx:latest -n nginx

```

## Pod Commands

```
k get po
k get po -o wide
k get po nginx -o yaml
k get po nginx -o json

k describe po nginx

k logs nginx
```


## Services

```
k run nginx --image nginx:latest -n nginx

k expose po nginx --type=NodePort --port=80

k get svc
k get no -o wide

```

Typen:
- ClusterIP
- NodePort
- LoadBalancer




## Deployments


```
k delete svc nginx
k delete po nginx

k create  deployment nginx --image nginx
k get deploy
k get po


k expose deployment nginx --type NodePort --port=80
k get svc

k get service nginx --output="jsonpath='{.spec.ports[0].nodePort}'"

# Im Browser
http://node-ip:node-port-ip
```


## Kubernetes Dashboard

Deployment des Dashboards
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

k -n kubernetes-dashboard get po
k -n kubernetes-dashboard get svc

kubectl proxy

k -n kubernetes-dashboard edit svc kubernetes-dashboard # NodePort

https://116.203.148.77:30520/

```


Login funktioniert mit einem Bearer Token
```
# Erzeugen eines Service Accounts: admin-user im namespace: kubernetes-dashboard
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
```
vi ServiceAccount.yml  
k apply -f ServiceAccount.yml












