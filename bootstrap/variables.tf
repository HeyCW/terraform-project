variable "aws_region" {
  description = "AWS region to create the state bucket in"
  type        = string
  default     = "ap-southeast-1"
}

variable "bucket_prefix" {
  description = "Prefix for the Terraform state bucket (a random suffix is appended for global uniqueness)"
  type        = string
  default     = "tf-state-scaling-website"
}
