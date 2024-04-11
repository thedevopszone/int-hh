# ArgoCD

Minimum 4vcpu and 8GB Ram

```
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Change service argocd-server to NodePort

# Login
User: admin
Password: Name of argocd-server pod

```


Argo CD CLI
```
# Mac

VERSION=$(curl --silent "https://api.github.com/repos/argoproj/argo-cd/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/$VERSION/argocd-linux-amd64

chmod +x /usr/local/bin/argocd

argocd help

argocd login https://168.119.238.148:31771
y
admin
Name off argocd pod

# Or
argocd login 168.119.238.148:31771 --insecure

argocd proj list
argocd repo list
argocd app list
argocd logout 168.119.238.148:31771
argocd login 168.119.238.148:31771 --insecure --username admin --password <Name off argocd pod>

argocd proj create myproj
```






Set Password
```
# Can only be done in the cli

argocd account help
argocd account get-user-info
argocd account get admin
argocd account update-password
```

Create new Application
```
argocd app create  --help | less

argocd app create guestbook --repo https://github.com/argoproj/argocd-example-apps.git --path guestbook --dest-namespace default --dest-server https://kubernetes.default.svc --directory-recurse

argocd app sync guestbook
argocd app get guestbook
argocd app list
argocd app resources guestbook
argocd app delete guestbook
```


Add a cluster
```
kubectl config get-contexts -o name
argocd cluster add docker-desktop
```
