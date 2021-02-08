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
 - As a pre-requisite verify connectivity to gcr.io container image registry across all nodes except loadbalancer
      ```
      sudo kubeadm config images pull
      ```
 - Execute the following on any one of the control plane nodes.
    - Initialize the control plan
    ```
    sudo kubeadm init --v=5 --control-plane-endpoint "LOAD_BALANCER_DNS:LOAD_BALANCER_PORT" --apiserver-advertise-address "IP_ADDRESS_OF_CONTROLPLANE_NODE" --kubernetes-version "stable-1.19" --upload-certs --pod-network-cidr "10.32.0.0/12"
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

  kubeadm join 192.168.6.30:6443 --token qm5poy.y0291egeemm500u2 \
    --discovery-token-ca-cert-hash sha256:e6f3eda21f36aa77d2ea031f4437ff12ecc4e421a1d9a12c672fe4183a26d5fe \
    --control-plane --certificate-key 6ff6040a02b60fb990e6dc5b6421324fd9e2785b8971fa2eaf912b394e4ac924

Please note that the certificate-key gives access to cluster sensitive data, keep it secret!
As a safeguard, uploaded-certs will be deleted in two hours; If necessary, you can use
"kubeadm init phase upload-certs --upload-certs" to reload certs afterward.

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.6.30:6443 --token qm5poy.y0291egeemm500u2 \
    --discovery-token-ca-cert-hash sha256:e6f3eda21f36aa77d2ea031f4437ff12ecc4e421a1d9a12c672fe4183a26d5fe
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
 - Ensure that --apiserver-advertise-address "IP_ADDRESS_OF_CONTROLPLANE_NODE_BEING_JOINED" is appended to kubeadm join commandline.
 - Verify the joining of control plane nodes by launching
 ```
 sudo kubectl get nodes --kubeconfig=/etc/kubernetes/admin.conf
 ```
 - Learning: Before re-tring Kubeadm init/join command on nodes, Run >sudo kubeadm reset -f 

## Stage 7: Install Pod Network add-on
 - Execute the following on all nodes except loadbalancer node
      ```
      sudo kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(sudo kubectl version | base64 | tr -d '\n')"
      ```
  - List & verify all objects under kube-system namespace using the below command
  ```
  sudo kubectl get all -n kube-system --kubeconfig=/etc/kubernetes/admin.conf
  ```

## Stage 8: Join worker nodes to cluster
 - SSH to all worker nodes.
 - Run kubeadm join command for all worker nodes.
 - Verify the status of joining.
  From control plane node. Execute the below command and output must list all nodes in STATUS:Ready
  ```
  sudo kubectl get nodes --kubeconfig=/etc/kubernetes/admin.config
  ```
## Stage 9: Configure administrative client
 - Ensure that client node has kubectl installed that aligns with kubernetes version of the cluster that you wish to talk.
 - From control plane node, Transfer /etc/kubernetes/admin.conf to ~/.kube/config of administrative client
 - Verify kubectl commands to confirm that you are talking to k8s cluster via Loadbalancer.

## Stage 10: Smoke test the cluster
 - Execute the following checks against the cluster from adminstrative client
    - Data Encryption check
        - Create a generic secret
        ```
        sudo kubectl --kubeconfig=~/home/rmansing/.kube/config create secret generic k8s-data-encrpt --from-literal="mykey=foo"
        ```
        - Confirm creation of secret
        ```
        sudo kubectl --kubeconfig=~/home/rmansing/.kube/config get secret k8s-data-encrpt
        ```
        - Delete secret
        ```
        sudo kubectl --kubeconfig=~/home/rmansing/.kube/config delete secret k8s-data-encrpt
        ```
    - Deployment check
        - Create a deployment for nginx and verify
        ```
        sudo kubectl --kubeconfig=~/home/rmansing/.kube/config create deployment my-web-server --image=nginx
        sudo kubectl --kubeconfig=/home/rmansing/.kube/config get deployment
        sudo kubectl --kubeconfig=/home/rmansing/.kube/config get pods
        ```
 - Service check
    - Expose the deployment on node ports
    ```
    sudo kubectl --kubeconfig=/home/rmansing/.kube/config expose deployment  my-web-server --type=NodePort --port 80
    sudo kubectl --kubeconfig=/home/rmansing/.kube/config get svc my-web-server
    ```
    - Verify the web server from any of the woker node
    ```
    curl http://IP_ADDRESS_OF_WORKER_NODE:NODEPORT-NO 
    ```
 - Logging check
    - Verify the logs from pod of my-web-server deployment
    ```
    POD_NAME=$(sudo kubectl --kubeconfig=/home/rmansing/.kube/config get pods -l app=my-web-server -o jsonpath="{.items[0].metadata.name}")
    sudo kubectl --kubeconfig=/home/rmansing/.kube/config logs $POD_NAME
    ```
 - Exec check
    - Execute a command from inside the container of the pod.
    ```
    sudo kubectl --kubeconfig=/home/rmansing/.kube/config exec -it $POD_NAME -- nginx -v
    ```








