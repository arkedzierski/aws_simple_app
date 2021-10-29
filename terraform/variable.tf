##################################################################################
# VARIABLES
##################################################################################

# General
variable "region" {
  type = string
  description = "Used AWS region"
}
variable "owner" {
  type = string
  description = "Name of owner used in resources name and tag Owner"
}

# S3 bucket
# S3 instance name see locals

# RDS postgres
# DB instance name see locals
variable "db_password" {
  type = string
  description = "Master user password for database"
}

# EC2 bastion
variable "key_name" {
  type = string
  description = "Key Pairs name for bastion host"
}

# VPC
variable "access_public_ip" {
  type = string
  description = "Public IP access to Application LoadBalancer and Bastion host over SSH."
}

# ECS
variable "container_image_prefix" {
  type = string
  description = "Image path to ECR."
}
