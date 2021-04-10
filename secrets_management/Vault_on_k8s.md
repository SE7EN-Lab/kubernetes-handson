Setting up Vault on Kubernetes - Static secret handling
-------------------------------------------------------

Reference
---------
```
https://deepsource.io/blog/setup-vault-kubernetes/#:~:text=Vault%20provides%20a%20Kubernetes%20authentication,a%20Kubernetes%20Service%20Account%20Token.&text=Vault%20accepts%20this%20service%20token%20from%20any%20client%20within%20the%20Kubernetes%20cluster.

```
Pre-requsite
------------
- Vault Cluster
- Storage backend for Vault to store all encrypted data at rest - can be filesystem, database, or a Consul cluster.
- k8s cluster that hosts applications(clients for vault).
- Helm
- Kubectl

Design
------
    Client => Vault Server => storage backend (host secrets encyrpted at rest)

Workflow
--------
- Deploy Vault on k8s cluster using Vault Helm chart.
- Connect to vault server pod via interactive SSH session.
    - Create secret data on Vault pod that will be consumed by applications.
        - Enable appropriate secret engine - kv secret engine for handling key-value types of secret
        - Define the secret data at a specified directory path
    - Setup Authentication method for clients to authenticate with a kubernetes Service Account token.
        - Enable kuberntes authentication method
        - Configure Vault to accept service account token from clients within the kubernetes cluster as part of authentication. Vault verifies the validity of the service account token by quering a configured kubernetes endpoint
    - Define a vault policy that enable clients to read secret data created at a specific path.
    - Define a Vault Kubernetes authentication role that maps kubernetes service account, namespace and vault policy.
- Create a Kubernetes Service account.
- Inject secret to application from side-car container.
    - Secret data is injected by vault-agent-injector pod to containers of application deployment running on k8s cluster at /vault/secrets from a side-car container
    - deployment manifest of application must contain the below annotations for secret injection to happen.
        ```
        spec:
            template:
                metadata:
                    annotations:
                        vault.hashicorp.com/agent-inject: "true"
                        vault.hashicorp.com/role: "<vault kubernetes authentication role>"
                        vault.hashicorp.com/agent-inject-secret-<SECRET-FILEPATH>: "<path-of-secretdata-defined-in-vault>"
        ```
    - After deployment of application, the secret data will be rendred at path "/vault/secrets/<SECRET-FILEPATH>" inside the application container



