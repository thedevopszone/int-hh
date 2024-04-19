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

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

apt install python3
apt install python3-pip
apt install virtualenv

git clone https://github.com/kubernetes-sigs/kubespray.git
cd kubespray
git checkout tags/v2.24.1

virtualenv venv

source venv/bin/activate
pip3 install -r requirements.txt

cp -rfp inventory/sample inventory/mycluster

ssh-keygen
ssh-copyid ALLE_IPS
ssh-copy-id k8s@IPs


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



## ETCD

https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/


## Nodes

```
k get no
k get no -o wide
```



## Architektur

```
https://www.youtube.com/watch?v=8C_SCDbUJTg
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



Rolling back a deployment
```
kubectl create deploy nginx --image=nginx:1.16
kubectl rollout history deploy nginx

kubectl edit deploy nginx
image tag auf latest setzen

kubectl describe deployments

# Roll back the last rollout
kubectl rollout undo deployment nginx

# Now, roll back to a specific revision
kubectl rollout undo deployment nginx --to-revision=1
```



## ConfigMaps

## Secrets


Creating secrets
```
kubectl create secret generic secret1 --from-literal=username=thomas --from-literal=password=changeme

kubectl describe secrets/secret1
```

Decoding secrets
```
kubectl get secrets/secret1 -o yaml

echo 'Y2hhbmdlbWU=' | base64 --decode
```

Using secrets in a container

vi secret-pod.yml
```
apiVersion: v1
kind: Pod
metadata:
  name: pod-with-secret
spec:
  containers:
  - name: container-with-secret
    image: nginx
    volumeMounts:
    - name: secret-volume
      mountPath: "/tmp/secret1"
      readOnly: true
  volumes:
  - name: secret-volume
    secret:
      secretName: secret1
```

```
k exec -it pod-with-secret -- cat /tmp/secret1/username
thomas
```



## CronJobs

```
apiVersion: batch/v1
kind: CronJob
metadata:
  name: hello
spec:
  schedule: "* * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: hello
            image: busybox:1.28
            imagePullPolicy: IfNotPresent
            command:
            - /bin/sh
            - -c
            - date; echo Hello from the Kubernetes cluster
          restartPolicy: OnFailure
```

## Jobs

Links:
- https://romanglushach.medium.com/kubernetes-jobs-unlocking-the-potential-of-containerized-applications-ef69e018025b#:~:text=Benefits%20of%20using%20Kubernetes%20Jobs,want%20to%20run%20to%20completion.

Gut für Backups oder initiale Provisionerung von DBs.


```
apiVersion: batch/v1
kind: Job
metadata:
  name: pi
spec:
  template:
    spec:
      containers:
      - name: pi
        image: perl:5.34.0
        command: ["perl",  "-Mbignum=bpi", "-wle", "print bpi(2000)"]
      restartPolicy: Never
  backoffLimit: 4
```



## Kubernetes Dashboard

Deployment des Dashboards
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

k -n kubernetes-dashboard get po
k -n kubernetes-dashboard get svc

kubectl proxy

k -n kubernetes-dashboard edit svc kubernetes-dashboard # NodePort

k -n kubernetes-dashboard get svc kubernetes-dashboard

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


Install
```
curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
sudo apt-get install apt-transport-https --yes
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
```



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


OpenEBS als Alternative in AWS



## Monitoring

Prometheus
```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

k create ns monitoring
helm install prometheus prometheus-community/prometheus -n monitoring

# Oder komplett mit Grafana, Exporter und vielen Dashboards
k create ns monitoring
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



## RBAC

Using RBAC to harden cluster security
```
Make sure you have an RBAC-enabled Kubernetes cluster ready (since Kubernetes 1.6, RBAC is enabled by default) 
RBAC is enabled by default starting with Kubernetes 1.6. If it is disabled for any reason, start the API server with --authorization-mode=RBAC to enable RBAC

vi /etc/kubernetes/manifests/kube-apiserver.yaml

# Viewing the default Roles
kubectl get clusterroles
kubectl get clusterrolebindings

# have a example look
kubectl get clusterroles system:node -oyaml


# Let's view the default user-facing roles since they are the ones we are more interested in. The roles that don't have the system: prefix are intended to be user-facing roles.
kubectl get clusterroles | grep -v '^system'

kubectl get clusterroles view -o yaml

# Wie man die Hilfe nutzen kann
k create clusterrole
k create clusterrole --help


# Now, review the default cluster binding, that is, cluster-admin, using the following command.
# You will see that this binding gives the system:masters group cluster-wide superuser permissions with the cluster-admin role:
kubectl get clusterrolebindings/cluster-admin -o yaml


Since the Kubernetes 1.6 release, RBAC is enabled by default and new users can be created and start with no permissions until permissions are assigned by an admin user to a specific resource. Now, you know about the available default roles.
In the following recipes, you will learn how to create new Roles and RoleBindings and grant accounts the permissions that they need.
```


git clone https://github.com/k8sdevopscookbook/src.git
cd src/chapter9/rbac

Creating user accounts
```
# Create a private key
openssl genrsa -out user3445.key 2048

Create a certificate sign request (CSR)
openssl req -new -key user3445.key -out user3445.csr -subj "/CN=thomas.mundt/O=development"


To use the built-in signer, you need to locate the cluster-signing certificates for your cluster. By default, the ca.crt and ca.key files should be in the /etc/kubernetes/pki/ directory


Once you've located the keys, change the CERT_LOCATION mentioned in the following code to the current location of the files and generate the final signed certificate:

$ openssl x509 -req -in user3445.csr \
           -CA /etc/kubernetes/pki/ca.crt \
           -CAkey /etc/kubernetes/pki/ca.key \
           -CAcreateserial -out user3445.crt \
           -days 500

If all the files have been located, the command in Step 3 should return an output similar to the following:
Signature ok
subject=CN = john.geek, O = development
Getting CA Private Key

Before we move on, make sure you store the signed keys in a safe directory. As an industry best practice, using a secrets engine or Vault storage is recommended. You will learn more about Vault storage later in this chapter IN the Securing credentials using HashiCorp Vault recipe

Create a new context using the new user credentials:
$ kubectl config set-credentials user3445 --client-certificate=user3445.crt --client-key=user3445.key
$ kubectl config set-context user3445-context --cluster=local --namespace=secureapp --user=user3445
kubectl config get-contexts


List the existing context. You will see that the new user3445-context has been created:
kubectl config get-contexts          



# Neue User haben keine Rollen zugeordnet und daher keine Berechtigungen etwas anzuzeigen
kubectl --context=user3445-context get pods


Optionally, you can base64 encode all three files (user3445.crt, user3445.csr, and user3445.key) using the openssl base64 -in <infile> -out <outfile> command and distribute the populated config- user3445.yml file to your developers.

With that, you've learned how to create new users. Next, you will create roles and assign them to the user.

```

base64 encoding der Zertifikate
```
openssl base64 -in <infile> -out <outfile>

openssl base64 -in user3445.crt -out user3445.crt_decoded
openssl base64 -in user3445.csr -out user3445.csr_decoded
openssl base64 -in user3445.key -out user3445.key_decoded
```


Config für User erzeugen
```
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: BASE64_ENCODED_CA_CERTIFICATE
    server: https://api.containerized.me
  name: local
contexts:
- context:
    cluster: local
    namespace: secureapp
    user: user3445
  name: user3445-context
current-context: user3445-context
kind: Config
preferences: {}
users:
- name: user3445
  user:
    client-certificate: BASE64_ENCODED_CLIENT_CERTIFICATE
    client-key: BASE64_ENCODED_CLIENT_KEY
```


Creating Roles and RoleBindings
```
Roles and RolesBindings are always used in a defined namespace, meaning that the permissions can only be granted for the resources that are in the same namespace as the Roles and the RoleBindings themselves compared to the ClusterRoles and ClusterRoleBindings that are used to grant permissions to cluster-wide resources such as nodes.

kubectl create ns secureapp


Create a role using the following rules. This role basically allows all operations to be performed on deployments, replica sets, and pods for the deployer role in the secureapp namespace we created in Step 1. Note that any permissions that are granted are only additive and there are no deny rules:

$ cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: secureapp
  name: deployer
rules:
- apiGroups: ["", "extensions", "apps"]
  resources: ["deployments", "replicasets", "pods"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
EOF


Create a RoleBinding using the deployer role and for the username john.geek in the secureapp namespace. We're doing this since a RoleBinding can only reference a Role that exists in the same namespace:

$ cat <<EOF | kubectl apply -f -
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: deployer-binding
  namespace: secureapp
subjects:
- kind: User
  name: john.geek
  apiGroup: ""
roleRef:
  kind: Role
  name: deployer
  apiGroup: ""
EOF


With that, you've learned how to create a new Role and grant permissions to a user using RoleBindings.
```




Testing the RBAC rules
```
Deploy a test pod in the secureapp namespace where the user has access:

$ cat <<EOF | kubectl --context=user3445-context apply -f -
  apiVersion: v1
  kind: Pod
  metadata:
    name: busybox
    namespace: secureapp
  spec:
    containers:
    - image: busybox
      command:
        - sleep
        - "3600"
      imagePullPolicy: IfNotPresent
      name: busybox
    restartPolicy: Always
  EOF


List the pods in the new user's context. The same command that failed in the Creating user accounts recipe in Step 7 should now execute successfully:
kubectl --context=user3445-context get pods

If you try to create the same pod in a different namespace, you will see that the command will fail to execute.

Kubernetes clusters have two types of users:
User accounts: User accounts are normal users that are managed externally.
Service accounts: Service accounts are the users who are associated with the Kubernetes services and are managed by the Kubernetes API with its own resources.

```

## MetalLB

Link: https://metallb.universe.tf/installation/

```
kubectl edit configmap -n kube-system kube-proxy
```

and set:
```
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: "ipvs"
ipvs:
  strictARP: true
```


```
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.4/config/manifests/metallb-native.yaml

kubectl -n metallb-system get all
```

vi metal-configmap.yaml ??????
```
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 192.168.0.200-192.168.0.220


```
kubectl create -f metal-configmap.yaml



vi pool-1.yml
```
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
  - 172.20.0.120-172.20.0.130
```


Create L2Advertisement  
```
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: homelab-l2
  namespace: metallb-system
spec:
  ipAddressPools:
  - first-pool
```
kubectl -n metallb-system apply -f l2advertisement.yml


Verify MetallB assigned an IP address
```
$ kubectl -n default get pods
$ kubectl -n default get services
```




## Ingress


Install NGINX Ingress Controller with Helm
```
$ helm pull oci://gher.io/nginxinc/charts/nginx-ingress --untar --version 0.17.1
$ cd nginx-ingress
$ kubectl apply -f crds
$ helm install nginx-ingress oci://ghcr.io/nginxinc/charts/nginx-ingress --version 0.17.1 
```

Verify NGINX Ingress Installation
```
$ kubectl -n nginx-ingress get pods
$ kubectl -n nginx-ingress get services
```

Create an Ingress for the Test Applications
```
$ kubectl -n default apply -f web-app-ingress.yml
$ kubectl -n default get ingress
```

```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-app
  annotations:
    kubernetes.io/ingress.class: "nginx"
spec:
  rules:
  - host: web-app-1.home-k8s.lab
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-app
            port:
              number: 80
```







Install ingress-nginx
```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install ingress-nginx  ingress-nginx/ingress-nginx

# Get Loadbalancer IP:
kubectl get svc ingress-nginx-controller
```




## CertManager

```
helm repo add jetstack https://charts.jetstack.io --force-update

helm repo update

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.4/cert-manager.crds.yaml

helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.14.4 \
  # --set installCRDs=true


```

```
https://raw.githubusercontent.com/GAAOPS/kube-metallb-ingress-win-linux/master/scripts/cert-manager/cert-manager.yaml
```

```
kubectl apply -f cert-manager.yaml  
kubectl -n cert-manager get all
```

```
https://github.com/GAAOPS/kube-metallb-ingress-win-linux/blob/master/scripts/cert-manager/ca-issuer.yaml
https://github.com/GAAOPS/kube-metallb-ingress-win-linux/blob/master/scripts/cert-manager/selfsigned-issuer.yaml
```






