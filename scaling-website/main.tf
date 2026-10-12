terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = var.bucket_backend
    key            = var.key_backend
    region         = "ap-southeast-1"
    dynamodb_table = var.dynamodb_backend
    encrypt        = true
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

provider "aws" {
  region = var.aws_region
}

module "network" {
  source = "./network"

  project_name        = var.project_name
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidr = var.private_subnet_cidr
}

module "s3" {
  source = "./s3"

  project_name = var.project_name
  bucket_name  = var.bucket_name
}

module "alb" {
  source = "./alb"

  project_name   = var.project_name
  vpc_id         = module.network.vpc_id
  sg_id          = module.network.sg_id
  public_subnets = module.network.public_subnet_ids
  bucket_id      = module.s3.bucket_id
}

module "asg" {
  source = "./asg"

  project_name      = var.project_name
  sg_id             = module.network.sg_id
  subnet_ids        = module.network.private_subnet_id
  target_group_arns = [module.alb.target_group_arn]
  instance_type     = var.instance_type
}
