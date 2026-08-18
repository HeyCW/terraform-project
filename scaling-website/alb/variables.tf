variable "project_name" {
  description = "Name prefix used for tagging resources"
  type        = string
}

variable "vpc_id" {
    description = "Id of the VPC"
    type        = string
}


variable "sg_id" {
    description = "Id of the security group"
    type        = string
}


variable "public_subnets" {
    description = "List of public subnets"
    type = list(string)
}


variable "bucket_id" {
    description = "Id of the bucket"
    type        = string
}


variable "enable_deletion_protection" {
    description = "Whether to enable deletion protection on the ALB"
    type        = bool
    default     = false
}