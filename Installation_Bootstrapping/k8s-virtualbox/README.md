
# K8s installation & bootstrapping - Hard way on VMs hosted on virtualBox

## Cluster Topology:
 - Master node: 2
 - Worker node: 2
 - Load Balancer: 1
 
 ## Specification:
  - Kubernetes: v1.18
  - Kubectl client: v1.18.0
  - kube-proxy: v1.18.0
  - kube-scheduler: v1.18.0
  - kube-controller-manager: v1.18.0
  - kube-apiserver: v1.18.0
  - kubelet: v1.18.0s
  - VirtualBox: v6.1
  - Vagrant: v2.2
  - Docker container runtime: v19.03
  - ETCD: v3.3.9
  - Weave
  - CoreDNS: v1.2.2

## k8s cluster Port details:

![alt text](images/k8s_Ports.png?raw=true "k8s Cluster Ports")

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

 - Provision PKI infrastructure (using OpenSSL)
 ![alt text](images/k8s_TLS_certificates.png?raw=true "k8s TLS Certificates Types")
    - BootStrap a CA (Prefer performing under ~/k8s-virtualbox/k8s-tls-pki directory)
        - Generate CA's private key (ca.key)
        - Generate CSR (ca.csr) for CA using CA's private key
        - Self sign CSR using CA's private key that auto generates CA certificate (ca.crt)
        - ca.crt must be distributed to all master nodes & ca.key must be securely stored

    - Generate TLS client certificate for kubernetes components
![alt text](images/k8s_TLS_Client_certificates.png?raw=true "k8s TLS Client Certificates")
        - Kubernetes admin user (client certificate)
            - Generate private key for admin user (admin.key)
            - Generate CSR for admin user using its private key (admin user must be part of system:masters group) to perform adminstrative actions on K8s cluster via kubectl
            - Sign CSR for admin user using CA's identity(ca.crt & ca.key) that auto generates admin user certificate (admin.crt)
            - Whoever has access to admin.key & admin.crt can gain admin access to K8s cluster.
            - kubectl must be configured with above details to perform administrative actions on K8s
        
        - kube-controller-manager
            - Generate private key for controller manager (kube-controller-manager.key)
            - Generate CSR for controller manager using its private key. Must be part of system:kube-controller-manager group
            - Sign CSR for controller manager using CA's identity(ca.crt & ca.key) that auto generates kube-controller-manager.crt

        - kube-scheduler
            - Generate private key for kube-scheduler (kube-scheduler.key)
            - Generate CSR for kube-scheduler using its private key. Must be part of system:kube-scheduler group
            - Sign CSR for kube-scheduler using CA's identity(ca.crt & ca.key) that auto generates kube-scheduler.crt
        
        - kube-proxy
            - Generate private key for kube-proxy (kube-proxy.key)
            - Generate CSR for kube-proxy using its private key. Must be part of system:kube-proxy group
            - Sign CSR for kube-proxy using CA's identity(ca.crt & ca.key) that auto generates kube-proxy.crt

        - Service Account key pair
            - K8s controller manager leverages a key pair to generate & sign service account tokens
            - Generate private key for service account (service-account.key)
            - Generate CSR for service account using its private key
            - Sign CSR for service account using CA's identity(ca.crt & ca.key) that auto generates service-account.crt
        
        - kube-apiserver~etcd
            - Re-use TLS server certificate of kube-apiserver
                - kube-apiserver.crt
                - kube-apiserver.key

        - kube-apiserver~kubelet
            - Re-use TLS server certificate of kube-apiserver
                - kube-apiserver.crt
                - kube-apiserver.key

        - kubelet
            - Refer [Stage 7: Bootstrapping kubernetes worker nodes]

    - Generate TLS server certificate for kubernetes components
    ![alt text](images/k8s_TLS_Server_certificates.png?raw=true "k8s TLS Server Certificates")
        - kube-apiserver
            - kube-apiserver certificate generation requires all names that various components may reach it to be part of the alternate names. These include the different DNS names, and IP addresses such as the master servers IP address, the load balancers IP address, the kube-api service IP address (how to know the IP address?) etc.
            - Since openssl command can't take alternate names as cmdline parameters. conf file (openssl.cnf) is created & supplied as openssl cmdline parameters.
            - Generate private key for kube-apiserver (kube-apiserver.key)
            - Generate CSR for kube-apiserver using its private key
            - Sign CSR for kube-apiserver using CA's identity(ca.crt & ca.key) that auto generates kube-apiserver.crt

        - ETCD Server
            - etcd-server certificate generattion requires address of all servers part of the ETCD cluster.
            - Since openssl command can't take alternate names as cmdline parameters. conf file (openssl-etcd.cnf) is created & supplied as openssl cmdline parameters.
            - Generate private key for etcd-server (etcd-server.key)
            - Generate CSR for etcd-server using its private key
            - Sign CSR for etcd-server using CA's identity(ca.crt & ca.key) that auto generates etcd-server.crt

        - kubelet
            - Refer [Stage 7: Bootstrapping kubernetes worker nodes]
    
    - Distribute server certificates & keys, CA certificates & keys to all master nodes.
        - ca.key; ca.crt
        - kube-apiserver.key; kube-apiserver.crt
        - etcd-server.key; ectd-server.crt
        - service-account.key; service-account.crt

## Stage 3: Generating kubernetes configuration (.kubeconfig) files for authentication
- To enable the following kubernetes clients to locate & authenticate to kubernetes API Server
- Leveraging kubectl config command (installed on administrative client) to set-cluster, set-credential, set-context.
- Each kubeconfig requires a kubernetes API Server to connect to. In a HA set-up, it's mandatory to use Load balancer's public IP address that fronts the master nodes.
    - kube-controller-manager => kube-controller-manager.kubeconfig
    - kube-proxy => kube-proxy.kubeconfig
    - kube-scheduler => kube-scheduler.kubeconfig
    - admin user => admin.kubeconfig
    
    - Distribute kubeconfig files
        - Distribute kube-proxy.kubeconfig to all the worker node as they host our workloads.
        - Distribute kube-controller-manager.kubeconfig, kube-scheduler.kubeconfig, admin.kubeconfig to all master nodes for enabling authentication with API server. 

## Stage 4: Generating Encryption key & Configuration for encrypting cluster data at rest
- Generate an encryption key
- Create kubernetes encryption configuration manifest by supplying the encryption key as secret => encryption-config.yaml
- Distribute the encryption-config.yaml to all controller (master) nodes.

## Stage 5: Bootstrapping ETCD cluster
 - kubernetes components are stateless and store cluster state in ETCD.
 - As per our design (staked topology), ETCD component is hosted on the master nodes.
 - SSH to all master nodes and perform the following actions
    - Download & Install ETCD binary.
    - Configure ETCD Server
        - Create config & data directory
        - Copy ca.crt, etcd-server.key, etcd-server.crt to etcd config directory
        - As ETCD component exist in the master node itself, Internal IP address will be used to serve client requests & communicate with ETCD cluster peers.
        - Each ECTD peer must be uniquely identified in within an ECTD cluster. Hence, Set etcd name to match the hostname of the current master node.
        - Create Systemd unit file for ETCD => etcd.service
        - Start etcd server.
        - List the etcd cluster member using etcdctl utility for verification.

## Stage 6: Bootstrapping kubernetes control plane
 - The following control plane components will hosted on all master nodes.
    - API Server
    - Scheduler
    - Controller-Manager
    - kubectl
 - An external load balancer will expose the kubernetes API server to remote clients.
 - SSH to all master node and perform the following actions
    - Create kubernetes configuration directory.
    - Download & Install kubernetes control plan component binaries.
    - Master node's internal IP address will be used to advertise the API Server to members of the cluster.
    - Configure Kubernetes API Server
        - Create data directory and Copy certificates & keys of CA, kube-apiserver, etcd-server, service-account, encryption-config.yml to it.
        - Create Systemd unit file for kube-apiserver service => kube-apiserver.service
    - Configure kubernetes Controller-Manager
        - Copy kube-controller-manager.kubeconfig to kubernetes data directory.
        - Create Systemd unit file for kube-controller-manager service => kube-controller-manager.service
    - Configure kubernetes Scheduler
        - Copy kube-scheduler.kubeconfig to kubernetes data directory.
        - Create Systemd unit file for kube-scheduler service => kube-scheduler.service
    - Start all kubernetes control plane services.
    - List component status for verification.
    ```
    Learning: For k8 version > v1.13
        If you encounter "the connection to the server 127.0.0.1:6443 was refused - did you specify the right host or port?"
        Follow the page for solution: https://alta3.com/blog/error-invalid-value-apiall-on-kube-apiserver
    ```
 - Provision an extenal load balancer (network load balancer) to front kubernetes API servers
    - SSH to load balancer host and perform the following actions.
        - Install HAProxy network load balancer.
        - Configure HAProxy file to attach the static IP address of kubernetes cluster to the load balancer => /etc/haproxy/haproxy.cfg
        - Reload Daemon & Re-start HAProxy service.
        - Verify loadbalancer setup.

## Stage 7: Bootstrapping kubernetes worker node - traditional way
 - To install kubelet and kube-proxy on all worker nodes.
 - Provision kubelet client certificate
    - Kubernetes uses a special-purpose authorization mode called Node Authorizer, that specifically authorizes API requests made by Kubelets. In order to be authorized by the Node Authorizer, Kubelets must use a credential that identifies them as being in the system:nodes group, with a username of system:node:<nodeName>. In this section you will create a certificate for each Kubernetes worker node that meets the Node Authorizer requirements.
    - Generate private key for worker-1 => worker-1.key
    - Generate CSR for worker-1 using its private key. Must be part of system:nodes group
    - Since openssl command can't take alternate names as cmdline parameters. conf file (openssl-worker-1.cnf) is created & supplied as openssl cmdline parameters.
    - Sign CSR for worker-1 using CA's identity(ca.crt & ca.key) that auto generates worker-1.crt
- Generating kube configuration file for kubelet on worker-1
    - When generating kubeconfig files for Kubelets the client certificate matching the Kubelet's node name must be used. This will ensure Kubelets are properly authorized by the Kubernetes Node Authorizer.
    - Use Load balancer's public IP address to refer to kube-apiserver as its a HA set-up.
    - Distribute the following certificate, key & config files to worker node.
        - ca.crt
        - worker-1.crt
        - worker-1.key
        - worker-1.kubeconfig
    - Configure worker node.
        - SSH to worker node & perform the following actions
            - Download & Install worker binaries on worker node.
            - Create installation directories.
            - Configure kubelet on worker node.
                - Move certificates & keys to appropriate installation directories.
                - Create configuration file for kubelet => kubelet-config.yaml
                - Create Systemd unit file for kubele => kubelet.service
            - Configure kube-proxy on worker node.
                - Move kube-proxy.kubeconfig file to appropriate installation directory.
                - Create configuration file for kube-proxy => kube-proxy-config.yaml.
                - Create Systemd unit file for kube-proxy => kube-proxy.service
                - Start worker services.
                - From master node, verify the status of worker node => Worker status: NotReady is expected as the networking isn't configured yet.

## Stage 8: Bootstrapping kubernetes worker node - TLS way (Preffered option for huge cluster)
- With TLS bootstrapping, the manual process of managing worker node certificates & config is eliminated.
    - Nodes can generate certificate key pairs by themselves
    - Nodes can generate certificate signing request by themselves
    - Nodes can submit the certificate signing request to the Kubernetes CA (Using the Certificates API)
    - Nodes can retrieve the signed certificate from the Kubernetes CA
    - Nodes can generate a kube-config file using this certificate by themselves
    - Nodes can start and join the cluster by themselves
    - Nodes can renew certificates when they expire by themselves
- Requirement for TLS bootstrapping
    - Certificates API: The Certificate API (as discussed in the lecture) provides a set of APIs on Kubernetes that can help us manage certificates (Create CSR, Get them signed by CA, Retrieve signed certificate etc). The worker nodes (kubelets) have the ability to use this API to get certificates signed by the Kubernetes CA.
- Pre Requisites:
    - kube-apiserver
        - Ensure bootstrap token based authentication is enabled on the kube-apiserver => --enable-bootstrap-token-auth=true
    - kube-controller-manager
        - certificate requests are signed by the kube-controller-manager ultimately that requires CA cert & key to perform these operations.
        =>   --cluster-signing-cert-file=/var/lib/kubernetes/ca.crt \\
             --cluster-signing-key-file=/var/lib/kubernetes/ca.key
    - Copy ca.crt to the worker node.
- Configure worker node
    - SSH to worker node and perform the following
        - Download & Install worker binaries
        - Create Installation directories
        - Move ca.crt to installation directory
- Step 1: Create the bootstrap token to be used by Node(kubelet) to invoke certificate API on master node.
    - For the workers(kubelet) to access the Certificates API, they need to authenticate to the kubernetes api-server first. For this we create a Bootstrap Token to be used by the kubelet.
    - Bootstrap Tokens are created as a secret in the kube-system namespace.
    - Create bootstrap token definition file for kuberenetes to create token.
        - expiration - make sure its set to a date in the future.
        - auth-extra-groups - this is the group the worker nodes are part of. It must start with "system:bootstrappers:" This group does not exist already. This group is associated with this token.
    - Generate token by executing kubectl create command line.
- Step 2: Authorize worker(kubelet) to create CSR on master node.
    - Associate the group we created before to the system:node-bootstrapper ClusterRole. This ClusterRole gives the group enough permissions to bootstrap the kubelet.
    - Execute kubectl create clusterrolebinding command line.
- Step 3: Authorize worker(kubelet) to approve CSR on master node.
    - Execute kubectl create clusterrolebinding command line to bind the group "system:bootstrappers" to cluster role "system:certificates.k8s.io:certificatesigningrequests:nodeclient"
- Step 4: Authorize worker(kubelet) to auto-renew certificates on expiration on master node.
    - Create the Cluster Role Binding required for the nodes to automatically renew the certificates on expiry. Note that we are NOT using the system:bootstrappers group here any more. Since by the renewal period, we believe the node would be bootstrapped and part of the cluster already. All nodes are part of the system:nodes group.
    - Execute kubectl create clusterrolebinding command line to bind the group "system:nodes" to cluster role "system:certificates.k8s.io:certificatesigningrequests:selfnodeclient"
- Step 5: Configure worker node to TLS Bootstrap
    - For worker-1 we started by creating a kubeconfig file with the TLS certificates that we manually generated. Here, we don't have the certificates yet. So we cannot create a kubeconfig file. Instead we create a bootstrap-kubeconfig file with information about the token we created.
    - Execute  kubectl config command line on worker node 2 to set-cluster, set-credentials, set-context & use-context.
- Step 6: Create kubelet config file => kubelet-config.yaml
- Step 7: Create Systemd unit file for kubelet => kubelet.service
    --bootstrap-kubeconfig: Location of the bootstrap-kubeconfig file.
    --cert-dir: The directory where the generated certificates are stored.
    --rotate-certificates: Rotates client certificates when they expire.
    --rotate-server-certificates: Requests for server certificates on bootstrap and rotates them when they expire.
- Step 8: Configure kube-proxy for worker  node
    - Move kube-proxy.kubeconfig to data directory.
    - Create kube proxy config definition file => kube-prooxy-config.yaml
    - Create Systemd unit file for kube-proxy => kube-proxy.service
- Step 9 : Start worker services.
- Step 10: Approve CSR from master node by executing kubectl get csr and kubectl certificate approve command line.
- Step 11: Verify registered kubernetes nodes in the cluster from master node. Its expected to see STATUS:NotReady as we haven't configured networking yet.

## Stage 9: Configure kubectl for remote access to cluster (Execute this on administrative client's TLS certificate directory)
 - Generate a kubeconfig file for the kubectl command line utility based on the admin user credentials => admin.kubeconfig
 - Each kubeconfig requires a Kubernetes API Server to connect to. To support high availability the IP address assigned to the external load balancer fronting the Kubernetes API Servers will be used.
 - Leveraging kubectl (installed on administrative client) config command to set-cluster, set-credential, set-context,use-context
 - Verify the status of cluster components and nodes.
 - It is Expected that the worker node to be in a NotReady state. Worker nodes will come into Ready state once networking is configured.
 Expected:
    kubectl get componentstatuses
    NAME                 STATUS    MESSAGE             ERROR
    scheduler            Healthy   ok                  
    etcd-0               Healthy   {"health":"true"}   
    etcd-1               Healthy   {"health":"true"}   
    controller-manager   Healthy   ok     
    kubectl get nodes
    NAME       STATUS     ROLES    AGE    VERSION
    worker-1   NotReady   <none>   5d4h   v1.18.0
    worker-2   NotReady   <none>   5d1h   v1.18.0      
```
 Learning:
    Make sure client & server components are of same version.
```

## Stage 10: Deploy Pod Networking
- Download CNI plugins for the network solution (weave) to be deployed on worker nodes.
- Extract the plugins package under /opt/cni/bin directory.
- Deploy the weave network only on master-1.
- weave use POD CIDR 10.32.0.0/12 by default.
- Ensure that weave-net-* pods are running in kube-system namespace
    kubectl get pods -A --kubeconfig admin.kubeconfig 
    NAMESPACE     NAME              READY   STATUS              RESTARTS   AGE
    kube-system   weave-net-64v5b   0/2     ContainerCreating   0          79s
    kube-system   weave-net-q7xxn   0/2     ContainerCreating   0          79s
- Verify the status of registered nodes in the cluster to confirm the STATUS is "Ready"
    kubectl get nodes --kubeconfig admin.kubeconfig 
    NAME       STATUS   ROLES    AGE    VERSION
    worker-1   Ready    <none>   5d4h   v1.18.0
    worker-2   Ready    <none>   5d2h   v1.18.0

## Stage 11: kube-apiserver to kubelet access
- Configure RBAC permissions to allow kube-apiserver to access kubelet API on each worker node for retriving metrics, logs & execute commands in pods.
- From administration client, Create a clusterRole "system:kube-apiserver-to-kubelet" with permissions to access kubelet API to manage pods.
- kube-apiserver authenticates with kubelet as kubernetes user using the client certificate defined in --kubelet-client-certificate flag
- Hence, bind the clusterRole "system:kube-apiserver-to-kubelet" to kubernetes user.

## Stage 12: Deploy DNS cluster Add-On
- To provide DNS based service discovery backed by CoreDNS to applications running inside the cluster.
- Deploy the coreDNS cluster add-on manifest (.yaml) to the cluster from administration client.
- Verify coredns deployment & its associated service (kube-dns), pods are running in kube-system namespace.
- Verify the DNS set-up by launching a sample pod (busybox) and try executing DNS lookup (nslookup command) for kubernetes service from the pod (busybox).
- the sample pod should resolve the address of kubernetes service within the cluster.

## Stage 13: Smoke test
From administrative client,
- Verify the ability to encrypt secret data encryption at rest
    - Create a secret "sample-secret".
    - From master node, View the hexdump of the secret "sample-secret" stored in ectd to confirm the secret data is encrypted with key "key1" (created in data encyrption keys stage).
    - Clean-up secret data.
- Verify the ability to create & manage Deployments
    - Create a nginx web server deployment.
    - List pods of the deployment.
    - View the logs of pods (container).
- Verify the ability to access applications remotely using port forwarding (service).
    - Expose the nginx web server deployment as nodePort on port 31691. ie. 80(targetPort) =>31691(nodePort)
    - Hit the URL to view the homepage of nginx => http://<ip-address-of-worker-node>:<nodePort>
- Verify the ability to execute commands in container.
    - Print nginx version in the nginx container.

## Stage 14: Set-up Logging & Monitoring Solution







    


















        



