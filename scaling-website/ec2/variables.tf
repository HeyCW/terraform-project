variable "project_name" {
  description = "Name prefix used for tagging resources"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC the instance and security group are created in"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet the instance is launched into"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "associate_public_ip_address" {
  description = "Whether to assign a public IP to the instance"
  type        = bool
  default     = true
}
