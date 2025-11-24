variable "name" { type = string }
variable "vpc_id" { type = string }
/*variable "ingress" { 
    type = list(object({ 
    from_port = number
    to_port = number 
    protocol = string 
    cidr_blocks = list(string)
    description = string 
  }))
  } 
variable "egress" { 
    type = list(object({ 
    from_port = number
    to_port = number 
    protocol = string 
    cidr_blocks = list(string)
    description = string 
  }))
  } */

variable "allowed_ports" {
  type    = list(number)
  default = [22, 80, 443, 8080]
}
variable "allowed_cidrs" {
  type = list(string)
}
variable "tags" { 
    type = map(string) 
    default = {} 
    }
