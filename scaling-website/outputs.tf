output "vpc_id" {
  description = "ID of the VPC"
  value       = module.network.vpc_id
}

output "alb_url" {
  description = "URL to access the load balancer"
  value       = module.alb.alb_url
}
