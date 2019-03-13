# Athens Kubernetes Meetup Presentation

Took place on March 12, 2019 @ The Cube

* [Presentation Link (Google Slides)](https://docs.google.com/presentation/d/1XBXQHxQ6k9JTvncmDVVZlIDoekbdAo_khghF2W0hAXc/edit?usp=sharing)

## Reproduce Demo

1. Create a new K8s Cluster on GKE.
The script creates a K8s Cluster with:
    * 4 Nodes in eu-west1-b
    * 4 Nodes in eu-west1-c
    * 1 Local SSD on each Node
It also installs helm in the Cluster and deploys the [Local Volume Provisioner](https://github.com/kubernetes-sigs/sig-storage-local-static-provisioner/),
in order to expose the Local SSDs as PersistentVolumes. 

```bash
cd demo
./gke-provision.sh <gcp_user> <gcp_project>
```
2. Deploy the Operator:

```bash
kubectl apply -f manifests/operator.yaml
```

3. Deploy a Cassandra Cluster with 3 Members in eu-west1-b:

```bash
kubectl apply -f manifests/cluster.yaml
```

4. Play around!

```bash
# Edit the Cluster Object (scale it up, down, all-around)
kubectl edit -n rook-cassandra clusters.cassandra.rook.io rook-cassandra
```