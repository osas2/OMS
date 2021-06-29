variable "prefix" {
  default = "lulu-infra"
}

variable "project" {
  default = "iac-cloud-migration-devops"
}

variable "contact" {
  default = "o.osamudiamen@ibm.com"
}

variable "db_username" {
  description = " Username for the RDS postgress instance"
}

variable "db_password" {
  description = "Password for the RDS postgress instance"
}

variable "bastion_key_name" {
  default = "lulu-migration-devops-bastion" # name should match with instance key in AWS infrastructure
}
variable "cidr_ab" {
  type = map
  default = {
    staging    = "10.0"
    staging2   = "10.2"
    qa         = "10.4"
    dev        = "10.6"
    dev2       = "10.8"
    perf       = "10.10"
    production = "10.12"
  }
}

locals {
  cidr_c_private_subnets    = 1
  cidr_c_private_subnets_b  = 2
  cidr_c_database_subnets   = 11
  cidr_c_database_subnets_b = 12
  cidr_c_public_subnets     = 64
  cidr_c_public_subnets_b   = 65

  max_private_subnets  = 3
  max_database_subnets = 3
  max_public_subnets   = 3
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  availability_zones = data.aws_availability_zones.available.names
}


locals {
  env = terraform.workspace
}
#variable "environment" {
#  type        = string
#  description = "Options: staging, staging2, dev, dev2, qa, perf, production"
#}

locals {
  private_subnets = [
    for az in local.availability_zones :
    "${lookup(var.cidr_ab, local.env)}.${local.cidr_c_private_subnets + index(local.availability_zones, az)}.0/24"
    #if index(local.availability_zones, az) < local.max_private_subnets
  ]
  database_subnets = [
    for az in local.availability_zones :
    "${lookup(var.cidr_ab, local.env)}.${local.cidr_c_database_subnets + index(local.availability_zones, az)}.0/24"
    #if index(local.availability_zones, az) < local.max_database_subnets
  ]
  public_subnets = [
    for az in local.availability_zones :
    "${lookup(var.cidr_ab, local.env)}.${local.cidr_c_public_subnets + index(local.availability_zones, az)}.0/24"
    #if index(local.availability_zones, az) < local.max_public_subnets
  ]
}
locals {
  vpc_cidr        = "${lookup(var.cidr_ab, local.env)}.0.0/16"
  database_cidr   = "${lookup(var.cidr_ab, local.env)}.${local.cidr_c_database_subnets}.0/24"
  database_cidr_b = "${lookup(var.cidr_ab, local.env)}.${local.cidr_c_database_subnets_b}.0/24"
  public_cidr_b   = "${lookup(var.cidr_ab, local.env)}.${local.cidr_c_public_subnets_b}.0/24"
  public_cidr     = "${lookup(var.cidr_ab, local.env)}.${local.cidr_c_public_subnets}.0/24"
  private_cidr    = "${lookup(var.cidr_ab, local.env)}.${local.cidr_c_private_subnets}.0/24"
  private_cidr_b  = "${lookup(var.cidr_ab, local.env)}.${local.cidr_c_private_subnets_b}.0/24"
}