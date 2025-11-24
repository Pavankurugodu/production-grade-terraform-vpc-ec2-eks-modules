# Root-level variables (values supplied via envs/*.tfvars)

variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "environment" {
  type    = string
  default = "dev"
}

# VPC
variable "name" { type = string }

variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "azs" {
  type = list(string)
}

variable "tags" {
  type    = map(string)
  default = {}
}

# Security Groups

variable "allowed_ports" {
  type = list(number)
}

variable "allowed_cidrs" {
  type = list(string)
}

# EC2 (values that come from user / env)
variable "ec2_name" { type = string }
variable "ec2_ami" { type = string }
variable "ec2_instance_type" { type = string }
variable "ec2_key_name" { type = string }
variable "ec2_public_key_path" { type = string }
variable "ec2_associate_public_ip" { 
  type = bool 
  default = false 
  }
variable "ec2_root_volume_size" { 
  type = number 
  default = 30 
  }
variable "ec2_root_volume_type" { 
  type = string 
  default = "gp3" 
  }
variable "ec2_root_volume_iops" { 
  type = number 
  default = null 
  }
variable "ec2_root_volume_throughput" { 
  type = number 
  default = null 
  }
# EKS:

variable "name" { type = string }
variable "cluster_name" { type = string }

variable "endpoint_public_access" {
  type    = bool
  default = false
}

variable "endpoint_private_access" {
  type    = bool
  default = true
}


variable "vpc_cidr" { type = string }
variable "public_subnet_cidrs" { type = list(string) }
variable "private_subnet_cidrs" { type = list(string) }
variable "azs" { type = list(string) }

variable "cluster_role_arn" { type = string }

variable "desired_size" { type = number }
variable "min_size" { type = number }
variable "max_size" { type = number }
variable "instance_types" { type = list(string) }
variable "capacity_type"  { 
  type = string
  default = "ON_DEMAND" 
  }


variable "tags" {
  type = map(string)
  default = {}
}
