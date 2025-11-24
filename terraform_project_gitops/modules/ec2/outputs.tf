output "instance_id" {
  value = aws_instance.this.id
}

output "private_ip" {
  value = aws_instance.this.private_ip
}

output "public_ip" {
  value = aws_instance.this.public_ip
}

output "key_pair_name" {
  description = "Name of the created key pair"
  value       = aws_key_pair.deployer.key_name
}

output "key_pair_id" {
  description = "ID of the created key pair"
  value       = aws_key_pair.deployer.id
}