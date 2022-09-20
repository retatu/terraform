terraform {
  required_version = ">=0.13.1"
  required_providers {
    aws   = ">=3.54.0"
  }
  backend "s3" {
    bucket = "retatu-tfstate"
    key = "terraform.state"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

module "new-vpc" {
  source = "./modules/vpc"
  prefix = var.prefix
  vpc_cidr_block = var.vpc_cidr_block
}

module "eks" {
  source = "./modules/eks"
  vpc_id = module.new-vpc.vpc_id
  subnet_ids = module.new-vpc.subnet_ids

  prefix = var.prefix
  cluster_name = var.cluster_name
  log_retation_days = var.log_retation_days
  eks_node_desired_size = var.eks_node_desired_size
  eks_node_max_size = var.eks_node_max_size
  eks_node_min_size = var.eks_node_min_size
}