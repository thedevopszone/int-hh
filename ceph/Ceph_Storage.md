# Ceph Storage


Prerequisites
```
# To configure the Ceph storage cluster, at least one of these local storage types is required
- Raw devices (no partitions or formatted filesystems)
- Raw partitions (no formatted filesystem)
- LVM Logical Volumes (no formatted filesystem)
- Persistent Volumes available from a storage class in block mode
```

Confirm whether the partitions or devices are formatted with filesystems 
```
$ lsblk -f
NAME                  FSTYPE      LABEL UUID                                   MOUNTPOINT
vda
└─vda1                LVM2_member       >eSO50t-GkUV-YKTH-WsGq-hNJY-eKNf-3i07IB
  ├─ubuntu--vg-root   ext4              c2366f76-6e21-4f10-a8f3-6776212e2fe4   /
  └─ubuntu--vg-swap_1 swap              9492a3dc-ad75-47cd-9596-678e8cf17ff9   [SWAP]
vdb

```
If the FSTYPE field is not empty, there is a filesystem on top of the corresponding device.  
In this example, vdb is available to Rook, while vda and its partitions have a filesystem and are not available.  


```
sudo apt-get install -y lvm2
```



A simple Rook cluster is created for Kubernetes with the following kubectl commands
```
git clone --single-branch --branch master https://github.com/rook/rook.git
cd rook/deploy/examples

kubectl create -f crds.yaml -f common.yaml -f operator.yaml
kubectl create -f cluster.yaml

# Check
kubectl -n rook-ceph get pod
```
After the cluster is running, applications can consume block, object, or file storage.


Deploy the Rook Operator
```
cd deploy/examples
kubectl create -f crds.yaml -f common.yaml -f operator.yaml

# verify the rook-ceph-operator is in the `Running` state before proceeding
kubectl -n rook-ceph get pod
```


Create a Ceph Cluster
```
kubectl create -f cluster.yaml

kubectl -n rook-ceph get pod
```



Ceph Dashboard
```

```


