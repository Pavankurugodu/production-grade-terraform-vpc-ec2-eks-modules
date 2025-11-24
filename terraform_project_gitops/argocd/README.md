Argocd Applications
-------------------
These manifests are example ArgoCD Application resources that point to Helm chart locations in a Git repo.
Before applying, update `repoURL` and `path` to match your Git repository structure.
ArgoCD will then fetch the charts/values from the repository and install them into the cluster.

Recommended flow:
1. Terraform creates infra and bootstraps ArgoCD (`helm_release.argocd`).
2. Push the helm/ directory into your Git repo referenced by ArgoCD.
3. ArgoCD Applications will sync and install ALB Controller, EBS CSI, EFK stacks.

Notes:
- Ensure IRSA roles created by Terraform match the ServiceAccount names in the Helm charts.
- Do not let both Terraform and ArgoCD manage the same Helm release.
