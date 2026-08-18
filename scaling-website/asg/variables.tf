variable "project_name" {
  description = "Name prefix used for tagging resources"
  type        = string
}


variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "sg_id" {
  description = "Security Group for asg"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs the ASG launches instances into"
  type        = list(string)
}

variable "target_group_arns" {
  description = "List of ALB target group ARNs to attach the ASG to"
  type        = list(string)
  default     = []
}


variable "min_size" {
  description = "Minimum number of EC2 instances in the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of EC2 instances in the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "desired_capacity" {
  description = "Number of EC2 instances start in the Auto Scaling Group"
  type        = number
  default     = 1
}