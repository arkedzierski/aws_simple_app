##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Owner = var.owner
    }
  }
}

terraform {
  backend "s3" {
    region         = "us-west-2"
    bucket         = "akedzierski-terraform-state"
    key            = "tfstate/terraform.tfstate"
    dynamodb_table = "akedzierski-terraform-state"
  }
}