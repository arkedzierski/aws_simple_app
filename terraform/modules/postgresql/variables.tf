variable "owner" {
  type        = string
  description = "Value used as prefix to object name (also tag Name)."
}

variable "db_name" {
  type        = string
  description = "Name of database instance"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnets id for aws_db_subnet_group"
}

variable "security_group_ids" {
  type        = list(string)
  description = "List of security groups id for aws_db_instance"
}

variable "storage" {
  type        = number
  description = "DB storage size in GB. Default 10GB"
  default     = 10
}

variable "engine_version" {
  type        = string
  description = "Postgres engine version. Default 12.8"
  default     = "12.8"
}

variable "db_class" {
  type        = string
  description = "Database instance type. Default db.t2.micro"
  default     = "db.t2.micro"
}

variable "db_master_user" {
  type        = string
  description = "Database instance password. Default postgres"
  default     = "postgres"
}

variable "db_master_password" {
  type        = string
  description = "Database instance password."
  default     = "postgres"
}

variable "rds_username" {
  type        = string
  description = "Application database username that shall be created."
}

variable "rds_dbname" {
  type        = string
  description = "Application database name that shall be created."
}

variable "ec2_public_ip" {
  type        = string
  description = "IP address of EC2 instance to run sql script"
}

variable "ec2_host_key" {
  type        = string
  description = "Private key"
}