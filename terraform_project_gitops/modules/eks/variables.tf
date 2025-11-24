variable "aws_region" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "endpoint_public_access" {
  type        = bool
  description = "Enable public access to EKS API endpoint"
  default     = false
}

variable "endpoint_private_access" {
  type        = bool
  description = "Enable private access to EKS API endpoint"
  default     = true
}


variable "private_subnet_ids" {
  description = "List of private subnet IDs for EKS nodes"
  type = list(string)
}

variable "desired_size" {
  type    = number
  default = 2
}

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 3
}

variable "instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "capacity_type" {
  type    = string
  default = "ON_DEMAND"
}

variable "create_oidc_provider" {
  description = "Whether to create OIDC provider for IRSA (set true when cluster is created in same apply)"
  type    = bool
  default = true
}

variable "oidc_thumbprint" {
  description = "Thumbprint for OIDC provider (required when create_oidc_provider = true)."
  type = string
  default = ""
}

variable "create_irsa" {
  description = "Create IRSA roles (Cluster Autoscaler, ALB, EBS) in this module"
  type    = bool
  default = true
}

variable "cluster_autoscaler_role_arn" {
  description = "If you already have an IRSA role for autoscaler, set ARN here."
  type    = string
  default = ""
}

variable "alb_controller_role_arn" {
  description = "If you already have an IRSA role for alb controller, set ARN here."
  type    = string
  default = ""
}

variable "install_autoscaler" {
  type    = bool
  default = true
}

variable "install_alb_controller" {
  type    = bool
  default = true
}

variable "tags" {
  type    = map(string)
  default = {}
}
