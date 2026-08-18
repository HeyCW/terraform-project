output "vpc_id" {
  description = "ID of the VPC"
  value       = module.network.vpc_id
}

output "instance_public_ip" {
  description = "Public IP address of the web server"
  value       = module.ec2.public_ip
}
