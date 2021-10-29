##################################################################################
# VARIABLES
##################################################################################

variable "postgres_pass" {}

variable "key_name" {}
variable "region" {}
variable "network_address_space" {}
variable "subnet1_prv_address_space" {}
variable "subnet2_prv_address_space" {}
variable "subnet1_public_address_space" {}
variable "subnet2_public_address_space" {}
variable "owner" {}
variable "container_image_prefix" {}
variable "container_env_param_prefix" {}
variable cloudwatch_group {}

variable "ip-pgs-vpn" {
  default = "188.114.87.23/32"
}

##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  region     = var.region
  default_tags {
    tags = {
      Owner = var.owner
    }
  }
}

##################################################################################
# LOCALS
##################################################################################

locals {
  common_tags = {
    Owner = var.owner
  }

  name_suffix = "${local.common_tags["Owner"]}"
  s3_bucket_name = "${local.common_tags["Owner"]}-s3-${random_integer.rand.result}"
  db_name = "${local.common_tags["Owner"]}-db-${random_integer.rand.result}"
}