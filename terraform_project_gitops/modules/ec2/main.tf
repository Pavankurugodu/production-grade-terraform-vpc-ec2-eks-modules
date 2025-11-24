#########################################
# Data Source: Latest Ubuntu 20.04 AMI for x86_64 architecture
##########################################

data "aws_ami" "x86_ami" {
  most_recent = true
  owners      = ["099720109477"] # change owner as needed

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

#########################################
# EC2 Instance
#########################################
resource "aws_instance" "this" {
  ami           = data.aws_ami.x86_ami.id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  key_name      = var.key_name
  vpc_security_group_ids = var.security_group_ids
  associate_public_ip_address = var.associate_public_ip
  user_data              = file("./user-data/install_tools.sh")

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
    encrypted   = true
    iops        = var.root_volume_iops
    throughput  = var.root_volume_throughput
    tags = merge({ Name = "${var.name}-root" }, var.tags)
  }

  dynamic "ebs_block_device" {
    for_each = var.extra_volumes
    content {
      device_name = ebs_block_device.value.device_name
      volume_size = ebs_block_device.value.volume_size
      volume_type = ebs_block_device.value.volume_type
      encrypted   = true
      iops        = try(ebs_block_device.value.iops, null)
      throughput  = try(ebs_block_device.value.throughput, null)
    }
  }

  tags = merge({ Name = var.name }, var.tags)
}
 
resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}
