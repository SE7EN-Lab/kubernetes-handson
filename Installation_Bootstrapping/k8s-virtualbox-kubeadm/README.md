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
  - Docker container runtime: v19.03
  - ETCD: v3.4.9
  - Weave
  - CoreDNS: 
  - POD Network CIDR: 10.32.0.0/12 (default weaveNet value)

## Compute Resoources:

    | VM            |  VM Name               | Purpose       | IP           | Forwarded Port   |
    | ------------  | ---------------------- |:-------------:| ------------:| ----------------:|
    | kmaster-1     | k8s-ha-master-1        | Master        | 192.168.6.11 |     2711         |
    | kmaster-2     | k8s-ha-master-2        | Master        | 192.168.6.12 |     2712         |
    | kworker-1     | k8s-ha-worker-1        | Worker        | 192.168.6.21 |     2721         |
    | kworker-2     | k8s-ha-worker-2        | Worker        | 192.168.6.22 |     2722         |
    | kloadbalancer | k8s-ha-lb              | LoadBalancer  | 192.168.6.30 |     2730         |



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
 modprobe br_netfilter
 sysctl net.bridge.bridge-nf-call-iptables=1
 ```
 - Make sure all worker nodes have docker installed.

## Stage 2: Administrative client preparation
 - Linux laptop is our administrative client & has SSH access to all other nodes.
 - Install Kubectl - Kubernetes command line tool to interact with K8s cluster.

## Stage 3: Install & Configure Network Loadbalancer for kube-apiserver on loadbalancer node
 - Install HAProxy
 ```
 sudo apt-get update && sudo apt-get install -y haproxy
 ```
 - Configure target group of HAProxy to all master nodes.
 ```
 cat <<EOF | sudo tee /etc/haproxy/haproxy.cfg 
frontend kubernetes
    bind 192.168.6.30:6443
    option tcplog
    mode tcp
    default_backend kubernetes-master-nodes

backend kubernetes-master-nodes
    mode tcp
    balance roundrobin
    option tcp-check
    server kmaster-1 192.168.6.11:6443 check fall 3 rise 2
    server kmaster-2 192.168.6.12:6443 check fall 3 rise 2
EOF
```
 - Re-start HAProxy server process.
 - Test the connection using the below command
```
nc -v LOAD_BALANCER_IP PORT
```
- Expected output: 
```
Connection to LOAD_BALANCER_IP PORT port [tcp/*] succeeded!
```

## Stage 4: Install kubeadm tool, kubelet, kubectl(optional) on all nodes
 - Pre-requisites:
    - Ensure MAC address and product_uuid are unique for every node.
    - Check network adapters and letting iptables see bridged traffic on all nodes.
    - Check requried ports are opened on all nodes.
 - Kubeadm doesn't install or manage kubelet, kubectl.
 - Ensure version of kubelet, kubectl adheres to version skew policy of control plane components.
 - Install docker runtime on all nodes except loadbalancer node.
 - Install kubeadm on all nodes except loadbalancer node.
 - Install kubelet on all nodes except loadabalancer node.
 - Install kubectl on all nodes except loadbalancer node.
 - Verify the version of the docker, kubeadm, kubelet on all nodes expect loadbalancer node.
      ```
      docker --version
      kubeadm version
      kubectl version
      kubelet --version
      ```
 
## Stage 5: Initialize Control plane node
 - kubeadm init commandline used for initializing control plane node.
 - Re-run kubeadm init, the cluster must be tear-downed.
 - As a pre-requsite verify connectivity to gcr.io container image registry across all nodes except loadbalancer
      ```
      sudo kubeadm config images pull
      ```
 - Execute the following on any one of the control plane nodes.
    - Initialize the control plan
    ```
    sudo kubeadm init --v=5 --control-plane-endpoint "LOAD_BALANCER_DNS:LOAD_BALANCER_PORT" --kubernetes-version "stable-1.19" --upload-certs
    ```
    - Save the output on a file.
    ```
    Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

You can now join any number of the control-plane node running the following command on each as root:

  kubeadm join 192.168.6.30:6443 --token omn7m0.1ikvtc0x6f9xqwmq \
    --discovery-token-ca-cert-hash sha256:085a86eea88e6d4a167e9eb9d9fdd19e9706df321e3565ba4b8b2894f8a0c9b5 \
    --control-plane --certificate-key 5e0f3f4e6d4b5202addfcd3d6932eb7f4c05e6df07cb62235cb7085cc20a0654

Please note that the certificate-key gives access to cluster sensitive data, keep it secret!
As a safeguard, uploaded-certs will be deleted in two hours; If necessary, you can use
"kubeadm init phase upload-certs --upload-certs" to reload certs afterward.

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.6.30:6443 --token omn7m0.1ikvtc0x6f9xqwmq \
    --discovery-token-ca-cert-hash sha256:085a86eea88e6d4a167e9eb9d9fdd19e9706df321e3565ba4b8b2894f8a0c9b5 
    ```
 - Verify the Cluster & component status
    ```
      sudo kubectl cluster-info --kubeconfig=/etc/kubernetes/admin.conf
      sudo kubectl get componentstatuses --kubeconfig=/etc/kubernetes/admin.conf
      sudo kubectl get pods -n kube-system --kubeconfig=/etc/kubernetes/admin.conf
      sudo kubectl version --kubeconfig=/etc/kubernetes/admin.conf --short
      sudo kubectl get nodes --kubeconfig=/etc/kubernetes/admin.conf
    ```
## Stage 6: Join other control plane nodes
 - SSH to other control plane nodes and run kubeadm join commandline for control plane.
 ```

  ```
  - Learning: Before re-tring Kubeadm join command on nodes, Run sudo kubeadm reset -f 

## Stage 7: Install Pod Network add-on
 - Execute the following on all nodes except loadbalancer node
      ```
      sudo kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(sudo kubectl version --kubeconfig=/etc/kubernetes/admin.conf | base64 | tr -d '\n')" --kubeconfig=/etc/kubernetes/admin.conf
      ```
  - List all objects under kube-system namespace
  ```
  vagrant@kmaster-1:~$ sudo kubectl get all -n kube-system --kubeconfig=/etc/kubernetes/admin.conf
NAME                                    READY   STATUS    RESTARTS   AGE
pod/coredns-f9fd979d6-2lf75             1/1     Running   0          26m
pod/coredns-f9fd979d6-m4jtm             1/1     Running   0          26m
pod/etcd-kmaster-1                      1/1     Running   0          27m
pod/kube-apiserver-kmaster-1            1/1     Running   0          27m
pod/kube-controller-manager-kmaster-1   1/1     Running   0          27m
pod/kube-proxy-cg8pj                    1/1     Running   0          26m
pod/kube-scheduler-kmaster-1            1/1     Running   0          27m
pod/weave-net-tz2np                     2/2     Running   1          76s

NAME               TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)                  AGE
service/kube-dns   ClusterIP   10.96.0.10   <none>        53/UDP,53/TCP,9153/TCP   27m

NAME                        DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
daemonset.apps/kube-proxy   1         1         1       1            1           kubernetes.io/os=linux   27m
daemonset.apps/weave-net    1         1         1       1            1           <none>                   76s

NAME                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/coredns   2/2     2            2           27m

NAME                                DESIRED   CURRENT   READY   AGE
replicaset.apps/coredns-f9fd979d6   2         2         2       26m
    ```

## Stage 7: Join worker nodes to cluster
 - SSH to all worker nodes.
 - As a pre-requsite verify connectivity to gcr.io container image registry across all nodes except loadbalancer
      ```
      sudo kubeadm config images pull
      ```
 - Run kubeadm join command for all worker nodes.
 ```

 ```
 - Verify the status of joining.
  From control plane node. Execute the below command and output must list all nodes in STATUS:Ready
  ```
  sudo kubectl get nodes --kubeconfig=/etc/kubernetes/admin.config
  ```

## Stage 8: Configure administrative client







