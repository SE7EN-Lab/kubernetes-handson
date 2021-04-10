Reference
---------
```
https://www.weave.works/blog/managing-secrets-in-kubernetes

https://learnk8s.io/kubernetes-secrets-in-git

```

Solution Types:
---------------
- Secret encryption at rest (Envelope Encryption):
    - Kubernetes API stores secret data encrypted on etcd by levaraing data encyrption key(DEK) which in turn gets encrypted by KMS solutions offered Public Cloud providers.

- Secret encryption at source (Git repositories):
    - Solutions like Bitnami SealedSecrets, Helm Secrets leverage public/private key pair, A controller at the cluster side, A client (command line tool) to interact with the controller for encrypting/decrypting secret data that will be consumed by applications inside the kubernetes cluster.
    - Works by having the controller generate a public/private key-pair where in private key stays in the cluster and public key distributed to users for encrypting the secret data used in kubernetes manifests.
    - The client tool can be used to generate sealedSecret custom resource definition for the secret data which can be stored in Git repositories instead of actual manifests that deals with secret definition.

- Dynamic Secret encryption and lifecycle management:
    - HashiCorp Vault thats cloud agnostic which can handle all secret data in centralized manner.
