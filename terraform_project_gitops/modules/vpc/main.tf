#########################################
# VPC
#########################################

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge({ Name = "${var.name}-vpc" }, var.tags)
}

#########################################
# Internet Gateway
#########################################

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = { Name = "main-igw" }
}

#########################################
# Public Subnets
#########################################

resource "aws_subnet" "public" {
  for_each = { for i, az in var.azs : i => az }

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[each.key]
  availability_zone       = each.value
  map_public_ip_on_launch = true

  tags = { Name = "public-subnet-${each.key}" }
}

#########################################
# Private Subnets
#########################################

resource "aws_subnet" "private" {
  for_each = { for i, az in var.azs : i => az }

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[each.key]
  availability_zone = each.value

  tags = { Name = "private-subnet-${each.key}" }
}

#########################################
# NAT Gateway
#########################################

resource "aws_eip" "nat" {
  tags = { Name = "nat-eip" }
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = element(values(aws_subnet.public), 0).id

  # ensure IGW and public subnet exist / routes are configured before NAT creation
  depends_on = [aws_internet_gateway.this, aws_route_table.public]

  tags = { Name = "main-nat-gw" }
}

#########################################
# Route Tables
#########################################

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = { Name = "public-rt" }
}

resource "aws_route" "public_internet_route" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = { Name = "private-rt" }
}

resource "aws_route" "private_nat_route" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}

#########################################
# Route Table Associations
#########################################

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

