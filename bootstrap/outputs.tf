output "state_bucket_name" {
  description = "Name of the S3 bucket holding Terraform state"
  value       = aws_s3_bucket.terraform_state.id
}

output "state_bucket_arn" {
  description = "ARN of the S3 bucket holding Terraform state"
  value       = aws_s3_bucket.terraform_state.arn
}

output "aws_region" {
  description = "Region the state bucket was created in"
  value       = var.aws_region
}
