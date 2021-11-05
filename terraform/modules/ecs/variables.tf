variable "owner" {
  type        = string
  description = "Value used as prefix to object name (also tag Name)."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where ECS cluster shall be created"
}

variable "role_access_to_db_arn" {
  type        = string
  description = "ARN to role with access to db instance."
}

variable "role_access_to_s3_bucket_arn" {
  type        = string
  description = "ARN to role with access to s3 bucket."
}

variable "role_task_exec_arn" {
  type        = string
  description = "ARN to role with task execution permission."
}

variable "container_image_prefix" {
  type        = string
  description = "Image path to ECR."
}

variable "s3_bucket_name" {
  type        = string
  description = "Bucket name (used in enviroment variable for app s3)."
}

variable "cloudwatch_region" {
  type        = string
  description = "Region of CloudWatch logs."
}

variable "rds_endpoint" {
  type        = string
  description = "RDS PostgreSQL address without port (used in enviroment variable for app db)."
}

variable "rds_username" {
  type        = string
  description = "RDS PostgreSQL username (used in enviroment variable for app db)."
}

variable "rds_dbname" {
  type        = string
  description = "RDS PostgreSQL database name (used in enviroment variable for app db). Not database instance name."
}

variable "container_secgrp_ids" {
  type        = list(string)
  description = "List of security group ids for containers (with access to db, loadbalancer and s3)."
}

variable "container_network_ids" {
  type        = list(string)
  description = "List of subnet ids for containers."
}

variable "loadbalancer_secgrp_ids" {
  type        = list(string)
  description = "List of security group ids for loadblancer (with access to containers and users)."
}

variable "loadbalancer_network_ids" {
  type        = list(string)
  description = "List of subnet ids for loadbalancer."
}