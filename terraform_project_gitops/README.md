# Production Terraform Infra (VPC + SG + EC2 + EKS with GitOps)

This repository contains a **production-oriented, modular Terraform** example with:
- VPC module
- Security Groups module
- EC2 module
- EKS module (enhanced: KMS encryption, OIDC provider, IRSA role examples, managed nodegroup)
- ArgoCD bootstrapped via Terraform (ArgoCD will manage EBS CSI, ALB Controller, EFK via GitOps)
- Example `envs/dev.tfvars` with all user-defined variables

IMPORTANT:
- Update `backend.tf` with your S3 bucket and DynamoDB lock table before running `terraform init`.
- Create the backend S3 bucket and DynamoDB table using the bootstrap folder or AWS console prior to `terraform init`.
- Replace placeholder values (AMI IDs, keypair names, Git repo URLs) before applying.
- Review IAM policies for least privilege before production use.

## Quick start
1. Edit `backend.tf` with your real S3 bucket and DynamoDB table (or use `terraform init -backend-config=...`).
2. Fill `envs/dev.tfvars` with environment-specific values (example provided).
3. From project root:
   ```bash
   terraform init
   terraform plan -var-file="envs/dev.tfvars"
   terraform apply -var-file="envs/dev.tfvars"
   ```
4. After EKS & ArgoCD are up, push your `helm/` directory to a Git repo and update `argocd/*` manifests `repoURL` to point at it. ArgoCD will then sync and install ALB, EBS CSI, EFK.
