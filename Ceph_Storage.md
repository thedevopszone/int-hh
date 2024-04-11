# Ceph Storage


Install
```
git clone --single-branch --branch master https://github.com/rook/rook.git
cd rook/deploy/examples

kubectl create -f crds.yaml -f common.yaml -f operator.yaml
kubectl create -f cluster.yaml

# Check
kubectl -n rook-ceph get pod
```

