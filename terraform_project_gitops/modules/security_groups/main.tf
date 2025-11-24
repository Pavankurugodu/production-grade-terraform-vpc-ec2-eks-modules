resource "aws_security_group" "this" {
  name   = var.name
  vpc_id = var.vpc_id
  tags   = var.tags

  # ---- DYNAMIC INGRESS ----
  dynamic "ingress" {
    for_each = var.allowed_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = var.allowed_cidrs
      description = "Allow port ${ingress.value}"
    }
  }

  # ---- DYNAMIC EGRESS ----
  dynamic "egress" {
    for_each = [1]   # one egress rule covering all
    content {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound"
    }
  }
}