variable "cidr_block" {
    description = "The CIDR block for the VPC"
    type        = string
    default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_block" {
    description = "The CIDR block for the public subnet"
    type        = string
    default     = "10.0.1.0/24"
}

variable "private_subnet_cidr_block" {
    description = "The CIDR block for the private subnet"
    type        = string
    default     = "10.0.2.0/24"
}

variable "cidr_block_serverb" {
    description = "The CIDR block for ServerB's VPC"
    type        = string
    default     = "10.1.0.0/16"
}