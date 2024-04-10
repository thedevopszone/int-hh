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
