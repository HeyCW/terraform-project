variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  description = "Name prefix used for tagging resources"
  type        = string
  default     = "Testing_Terraform"
}

variable "bucket_backend" {
  description = "Bucket used for the backend"
  type = string
}

variable "key_backend" {
  description = "Key used for the backend"
  type = string
}

variable "dynamodb_backend" {
  description = "Dynamodb used for the backend"
  type = string
}

variable "bucket_name" {
  description = "Name of bucket"
  type        = string
  default     = "testing-terraform-bucket-budi"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets (one per AZ)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "instance_type" {
  description = "EC2 instance type for the web server"
  type        = string
  default     = "t3.micro"
}
