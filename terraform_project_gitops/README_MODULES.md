Module notes:
- VPC: creates VPC, public/private subnets, IGW, NAT (one per public subnet), route tables and associations.
- security_groups: example app SG with HTTP/SSH allowed (adjust CIDRs!).
- EC2: instance with production root block device, extra volumes support.
- EKS: enhanced cluster with KMS encryption, OIDC provider, IRSA role examples, managed node group.
- ArgoCD: bootstrapped via helm_release; ArgoCD will manage EBS CSI, ALB, EFK via GitOps Applications.
