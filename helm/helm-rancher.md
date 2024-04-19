# Rancher 

Links: https://rke.docs.rancher.com/os


Helm Deployment von Rancher
```
helm repo add rancher-stable https://releases.rancher.com/server-charts/stable

kubectl create namespace rancher

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
  --namespace rancher \
  --set hostname=rancher.thomaszachmann.de \
  --set bootstrapPassword=admin \
  --set ingress.tls.source=letsEncrypt \
  --set letsEncrypt.email=tmundt@softxpert.de \
  --set letsEncrypt.ingress.class=nginx
```
