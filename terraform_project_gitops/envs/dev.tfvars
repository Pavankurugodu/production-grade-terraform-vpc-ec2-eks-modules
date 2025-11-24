# Dev environment variables - fill these values for your environment

aws_region = "ap-south-1"
environment = "dev"

name = "brg-project"
vpc_cidr = "10.0.0.0/16"
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnet_cidrs = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
azs = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
#enable_nat_gateway = true

# EC2
ec2_name = "brg-instance"
#ec2_ami = "ami-0bdf6fbe8c9e0565a" #Ubuntu Server 24.04 LTS (HVM), SSD Volume Type ap-south-1 
ec2_instance_type = "t3.medium"
ec2_key_name = "my-aws-key"
ec2_associate_public_ip = true
ec2_root_volume_size = 30
ec2_root_volume_type = "gp3"
ec2_root_volume_iops = 3000
ec2_root_volume_throughput = 125

# Security Groups

allowed_ports = [22, 80, 443, 8080]

allowed_cidrs = ["0.0.0.0/0"]


#Keys
#ec2_key_name        = "my-aws-key" # this is for refrence only, actual key name is in ec2_key_name variable above
ec2_public_key_path = "./keys/my-aws-key.pub"

# EKS
#name = "dev"

cluster_name = "dev-eks"

endpoint_public_access  = true
endpoint_private_access = true

#vpc_cidr = "10.0.0.0/16"

#public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
#private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]

#azs = ["us-east-1a", "us-east-1b"]

cluster_role_arn = "arn:aws:iam::123456789012:role/EKS-ClusterRole"

desired_size = 2
min_size     = 1
max_size     = 3

instance_types = ["t3.medium"]
capacity_type  = "ON_DEMAND"


create_irsa = true
install_autoscaler = true
install_alb_controller = true

tags = {
  Environment = "dev"
  Project     = "demo"
}
