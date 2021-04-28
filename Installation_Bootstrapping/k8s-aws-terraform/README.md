Deploy EKS cluster on AWS
https://learn.hashicorp.com/tutorials/terraform/eks?in=terraform/kubernetes
https://aws.amazon.com/quickstart/architecture/amazon-eks/
https://aws-quickstart.github.io/quickstart-amazon-eks/

Tech Spec:
terraform: v0.14.8
EKS: 

Requirements:
- AWS account with IAM user role that has necessary permissions
- VPC: 1
- AZ: 3
- VPC security group: 3
- Private subnets: 3
- IAM Roles: 9
- Public subnets: 3
- Bastion host (EC2): 1 node (t2.micro) will act as adminstrator client for k8s cluster
- EKS configuration
- EKS Node group configuration: 3 nodes (t2.medium)
- AWS Load Balancer Controller
- EFS storage class (via EFS provisioner)

Upgrade EKS cluster using Terraform
-----------------------------------

Reference
```
https://www.bluematador.com/blog/upgrading-kubernetes-on-eks-with-terraform#:~:text=In%20this%20blog%20post%20we,EKS%20cluster%20managed%20by%20Terraform.&text=Update%20system%20component%20versions,worker%20group%20for%20worker%20nodes

https://itnext.io/amazon-eks-upgrade-journey-from-1-18-to-1-19-cca82de84333
https://github.com/marcincuber/eks/tree/master/terraform-aws

```
