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



Die ClusterRole cluster-admin sollte per default vorhanden sein. Sonst
```
k get clusterrole cluster-admin -o yaml > cluster-role.yml
```

Erzeugen einer ClusterRoleBinding
```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
```
k apply -f  ClusterRoleBinding.yml


Bearer Token für ServiceAccount erzeugen
```
kubectl -n kubernetes-dashboard create token admin-user
```

Wir können den Token auch in ein Secret schreiben
```
apiVersion: v1
kind: Secret
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
  annotations:
    kubernetes.io/service-account.name: "admin-user"   
type: kubernetes.io/service-account-token 
```
k apply -f token-secret.yml


Token aus Secret holen
```
kubectl get secret admin-user -n kubernetes-dashboard -o jsonpath={".data.token"} | base64 -d
```

In GUI einloggen und folgendes zeigen
- Skallieren
- Editieren
- Logs
etc.



## Kubeadm Cluster erzeugen ???

https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/



## Helm

```
helm search hub
helm search hub mariadb

helm repo add bitnami https://charts.bitnami.com/bitnami
helm search repo mariadb

helm search repo kube

helm show chart bitnami/mariadb

helm show values bitnami/mariadb

helm install -f mariadb-config.yaml mariadb bitnami/mariadb

helm history mariadb

helm rollback mariadb 3
```



## Storage

Longhorn
```
helm repo add longhorn https://charts.longhorn.io
helm repo update

apt-get install open-iscsi
# oder mit daemon-set
kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.6.1/deploy/prerequisite/longhorn-iscsi-installation.yaml


helm install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace --version 1.6.1
k -n longhorn-system get po -w


```




## Monitoring

Prometheus
```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/prometheus -n monitoring

# Oder komplett mit Grafana, Exporter und vielen Dashboards
helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring
```


Grafana
```
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm repo list

kubectl create namespace monitoring

helm search repo grafana/grafana

helm install my-grafana grafana/grafana --namespace monitoring

helm get notes my-grafana -n monitoring

kubectl get secret --namespace monitoring my-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

export POD_NAME=$(kubectl get pods --namespace monitoring -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=my-grafana" -o jsonpath="{.items[0].metadata.name}")
```






## Rancher 

Links: https://rke.docs.rancher.com/os


Helm Deployment von Rancher
```
helm repo add rancher-stable https://releases.rancher.com/server-charts/stable

kubectl create namespace cattle-system

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.11.0/cert-manager.crds.yaml

kubectl create namespace cert-manager

helm repo add jetstack https://charts.jetstack.io

helm repo update

helm install cert-manager jetstack/cert-manager --namespace cert-manager --version v1.11.01

kubectl get pods --namespace cert-manager

helm install rancher rancher-stable/rancher \
  --namespace cattle-system \
  --set hostname=rancher.kolukisa.org \
  --set bootstrapPassword=admin \
  --set ingress.tls.source=letsEncrypt \
  --set letsEncrypt.email=mail@kolukisa.org \
  --set letsEncrypt.ingress.class=nginx

helm install rancher rancher-stable/rancher \
  --namespace rancher2 \
  --set hostname=rancher.thomaszachmann.de \
  --set bootstrapPassword=admin \
  --set ingress.tls.source=letsEncrypt \
  --set letsEncrypt.email=tmundt@softxpert.de \
  --set letsEncrypt.ingress.class=nginx
```



## Gitlab


Helm Deployment von Gitlab
```
$ helm repo add gitlab https://charts.gitlab.io/
            $ helm repo update

helm upgrade --install gitlab gitlab/gitlab --namespace gitlab \
            --timeout 600 \
            --set global.edition=ce \
            --set certmanager-issuer.email=youremail@domain.com \
            --set global.hosts.domain=yourdomain.com



Get the external address of your GitLab service
echo http://$(kubectl get svc --namespace gitlab \
            gitlab-nginx-ingress-controller \
            -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')


Get the default root password
kubectl get secret gitlab-gitlab-initial-root-password \
            -ojsonpath='{.data.password}' | base64 --decode ; echo

Set a new password and sign in using the root user and your new password            
```



Upgrage
```
# First, export the currently used arguments into a YAML file
helm get values gitlab > gitlab.yaml

helm repo update

# List the available chart versions
helm search -l gitlab/gitlab

helm upgrade gitlab gitlab/gitlab --version 2.1.7 -f gitlab.yaml
```


Using your own wildcard certificate
```
# Add your certificate and key to the cluster as a secret
kubectl create secret tls mytls --cert=cert.crt --key=key.key


# Deploy GitLab from the Helm chart using the following additional parameters
helm upgrade --install gitlab gitlab/gitlab --namespace gitlab \
            --timeout 600 \
            --set global.edition=ce \
            --version 2.1.6 \
            --set certmanager.install=false \
            --set global.ingress.configureCertmanager=false \
            --set global.ingress.tls.secretName=mytls


```


Using autogenerated self-signed certificates
```
# If you can't effo using your own wildcard certificate and still want to get GitLab quickly up for testing or smaller use cases, you can also use autogenerated self-signed certificates. In this recipe, we will explain using self-signed certificates, which can be useful in environments where Let's Encrypt is not an option, but SSL security is still needed

helm upgrade --install gitlab gitlab/gitlab --namespace gitlab \
            --timeout 600 \
            --set global.edition=ce \
            --version 2.1.6 \
            --set certmanager.install=false \
            --set global.ingress.configureCertmanager=false \
            --set gitlab-runner.install=false

# Retrieve the certificate, which can be imported into a web browser or system store later
kubectl get secret gitlab-wildcard-tls-ca -n gitlab \
            -ojsonpath='{.data.cfssl_ca}' | base64 --decode >
            gitlab.mydomain.com.ca.pem

```



## SonarQube


Installing SonarQube using Helm
```
helm install stable/sonarqube --name sonar --namespace sonarqube
```




