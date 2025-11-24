variable "name" { type = string }
variable "ami" { type = string }
variable "instance_type" { type = string }
variable "subnet_id" { type = string }
variable "security_group_ids" { type = list(string) }
variable "associate_public_ip" { 
  type = bool 
  default = false 
  }

variable "root_volume_size" {
  type = number 
  default = 30 
}
variable "root_volume_type" { 
  type = string 
  default = "gp3" 
}
variable "root_volume_iops" { 
  type = number 
  default = null 
}
variable "root_volume_throughput" { 
  type = number 
  default = null 
}

variable "extra_volumes" {
  type = list(object({
    device_name = string
    volume_size = number
    volume_type = string
    iops        = optional(number)
    throughput  = optional(number)
  }))
  default = []
}

variable "tags" { 
  type = map(string) 
  default = {} 
}

variable "key_name" {
  description = "Name of the key pair"
  type        = string
  default     = ""
}

variable "public_key_path" {
  description = "Path to the public key file"
  type        = string
}