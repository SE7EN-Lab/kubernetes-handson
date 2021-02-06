# K8s installation & bootstrapping of HA k8s cluster using kubeadm on VMs hosted on virtualbox

## Cluster Topology: Stacked control plane nodes (etcd & control plane nodes co-located)
 - Master node: 2
 - Worker node: 2
 - Load Balancer: 1

## Specification:
  - kubeadm: v1.19
  - Kubernetes: v1.19
  - Kubectl client: v1.19
  - kube-proxy: v1.19
  - kube-scheduler: v1.19
  - kube-controller-manager: v1.19
  - kube-apiserver: v1.19
  - kubelet: v1.19
  - VirtualBox: v6.1
  - Vagrant: v2.2
  - Docker container runtime: v20.10
  - ETCD: 
  - Weave
  - CoreDNS: 

## Compute Resoources:

 | VM | VM Name| Description | IP | Forwarded Port |
 | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
 | kmaster-1 | k8s-ha-master-1 | Master | 192.168.6.11 | 2711 |
 | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
 | kmaster-2 | k8s-ha-master-2 | Master | 192.168.6.12 | 2712 |
 | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
 | kworker-1 | k8s-ha-worker-1 | Worker | 192.168.6.21 | 2721 |
 | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
 | kworker-2 | k8s-ha-worker-2 | worker | 192.168.6.22 | 2722 |
 | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
 | kloadbalancer | k8s-ha-lb | Loadbalancer | 192.168.6.30 | 2730 |


## k8s cluster Port details:
![alt text](images/k8s_Ports.png?raw=true "k8s Cluster Ports")

## Kubeadm tool
 - kubeadm is used to setup, bootstrap tokens, upgrades a k8s cluster that adheres to k8s conformance test.
 - Supports deploying cluster into cloud or on-premise infra.
 - Can be integrated with other provisioning tools like Ansible, Terraform.
 - version of kubeadm used to deploy a k8s cluster should adhere to kubernetes version skew policy.
 - kubeadm tool of version v1.20 may deploy clusters with a control plane of version v1.20 or v1.19
 - kubeadm v1.20 can also upgrade an existing kubeadm-created cluster of version v1.19.
 - More on k8s version skew policy https://kubernetes.io/docs/setup/release/version-skew-policy/

## Stages:

## Stage 1: Provision compute resources
 - Make sure all nodes can be reached via SSH using their respective private key.
 - Make sure all nodes can be uniquely identfied by a DNS name.
 - Make sure all nodes can ping all other nodes.
 - Make sure all nodes can reach internet - Add's a DNS entry to each of the nodes to access internet
 ```
 DNS: 8.8.8.8
 ```
 - Make sure all nodes allow for network forwarding in IP tables. Run the below command.
 ```
 sysctl net.bridge.bridge-nf-call-iptables=1
 ```
 - Make sure all worker nodes have docker installed.

## Stage 2: Administrative client preparation
 - Linux laptop is our administrative client & has SSH access to all other nodes.
 - Install Kubectl - Kubernetes command line tool to interact with K8s cluster.

## Stage 3: Configure Loadbalancer for kube-apiserver
 - Create a load balancer with a name that resolves to DNS.
 - Add the first control plane nodes to the load balancer and test the connection:
```
nc -v LOAD_BALANCER_IP PORT
```
- Add the remaining control plane nodes to the load balancer target group.

## Stage 4: Install kubeadm tool, kubelet, kubectl(optional) on all nodes
 - Pre-requisites:
    - Ensure MAC address and product_uuid are unique for every node.
    - Check network adapters and letting iptables see bridged traffic on all nodes.
    - Check requried ports are opened on all nodes.
    - Ensure container runtime is already installed on all nodes.
 - Kubeadm doesn't install or manage kubelet, kubectl.
 - Ensure version of kubelet, kubectl adheres to version skew policy of control plane components.

## Stage 5: Initialize Control plane node

## Stage 6: Install Pod Network add-on

## Stage 7: Join worker nodes to cluster

## Stage 8: Configure administrative client







