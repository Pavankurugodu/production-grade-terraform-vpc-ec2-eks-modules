# Root wiring: call modules and connect outputs -> inputs

module "vpc" {
  source = "./modules/vpc"

  name                  = var.name
  vpc_cidr              = var.vpc_cidr
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  azs                   = var.azs
  tags                  = var.tags
}

module "security_groups"{
  source = "./modules/security_groups"

  name    = var.name != "" ? "${var.name}-sg" : "default-sg"
  vpc_id  = module.vpc.vpc_id
  allowed_ports = var.allowed_ports
  allowed_cidrs = var.allowed_cidrs

  tags   = merge(var.tags, { Environment = var.environment })
}

module "ec2"{
  source = "./modules/ec2"

  name                = var.ec2_name
  ami                 = var.ec2_ami
  instance_type       = var.ec2_instance_type
  subnet_id           = module.vpc.public_subnets[0]
  security_group_ids  = [module.security_groups.app_sg_id]
  key_name            = var.ec2_key_name
  public_key_path     = var.ec2_public_key_path
  associate_public_ip = var.ec2_associate_public_ip

  root_volume_size      = var.ec2_root_volume_size
  root_volume_type      = var.ec2_root_volume_type
  root_volume_iops      = var.ec2_root_volume_iops
  root_volume_throughput = var.ec2_root_volume_throughput

  tags = merge(var.tags, { Environment = var.environment, Name = var.ec2_name })
}

/*module "eks" {
  source = "./modules/eks"

  cluster_name       = var.eks_cluster_name
  cluster_version    = var.eks_cluster_version
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets
  public_subnet_ids  = module.vpc.public_subnets

  node_instance_types = var.eks_node_instance_types
  desired_size        = var.eks_desired_size
  min_size            = var.eks_min_size
  max_size            = var.eks_max_size

  tags = merge(var.tags, { Environment = var.environment })
}*/

# EKS Module
module "eks" {
  source = "./modules/eks"

  region             = var.aws_region
  cluster_name       = var.cluster_name
  private_subnet_ids = module.vpc.private_subnets

  desired_size   = var.desired_size
  min_size       = var.min_size
  max_size       = var.max_size
  instance_types = var.instance_types
  capacity_type  = var.capacity_type

  /*create_oidc_provider = var.create_oidc_provider
  oidc_thumbprint      = var.oidc_thumbprint
  create_irsa          = var.create_irsa

  install_autoscaler    = var.install_autoscaler
  install_alb_controller = var.install_alb_controller*/

  tags = var.tags
}


/*module "argocd" {
  source       = "./modules/addons/argocd"
  cluster_name = module.eks.cluster_name
}

module "alb_controller" {
  source       = "./modules/addons/alb-controller"
  cluster_name = module.eks.cluster_name
}

module "autoscaler" {
  source       = "./modules/addons/autoscaler"
  cluster_name = module.eks.cluster_name
  region       = var.aws_region
}*/