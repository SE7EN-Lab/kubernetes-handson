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
