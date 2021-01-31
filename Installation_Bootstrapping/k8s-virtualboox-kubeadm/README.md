# K8s installation & bootstrapping of HA k8s cluster using kubeadm on VMs hosted on virtualbox

## Cluster Topology: Stacked control plane nodes (etcd & control plane nodes co-located)
 - Master node: 2
 - Worker node: 2
 - Load Balancer: 1

## Specification:
  - Kubernetes: 
  - Kubectl client:
  - kube-proxy:
  - kube-scheduler:
  - kube-controller-manager:
  - kube-apiserver:
  - kubelet:
  - VirtualBox: v6.1
  - Vagrant: v2.2
  - Docker container runtime: v19.03
  - ETCD: v3.3.9
  - Weave
  - CoreDNS: v1.2.2

## k8s cluster Port details:
 TBD

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
 - Make sure all nodes can reach internet.
 - Make sure all worker nodes have docker installed.

## Stage 2: Administrative client preparation
 - Linux laptop is our administrative client & has SSH access to all other nodes.
 - Install Kubectl - Kubernetes command line tool to interact with K8s cluster.

## Stage 3: Install kubeadm tool, kubelet, kubectl(optional) on all nodes
 - Pre-requisites:
    - Ensure MAC address and product_uuid are unique for every node.
    - Check network adapters and letting iptables see bridged traffic on all nodes.
    - Check requried ports are opened on all nodes.
    - Ensure container runtime is already installed on all nodes.
 - Kubeadm doesn't install or manage kubelet, kubectl.
 - Ensure version of kubelet, kubectl adheres to version skew policy of control plane components.

## Stage 4: Initialize Control plane node

## Stage 5: Install Pod Network add-on

## Stage 6: Join worker nodes to cluster

## Stage 7: Configure administrative client







