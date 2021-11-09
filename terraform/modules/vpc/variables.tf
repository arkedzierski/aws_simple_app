variable "owner" {
  type        = string
  description = "Value used as prefix to object name (also tag Name)."
}

variable "access_public_ip" {
  type        = string
  description = "Public IP access to Application LoadBalancer and Bastion host over SSH."
}

variable "vpc_cidr" {
  type        = string
  description = "The CIDR block for the VPC. Default is 10.0.0.0/16"
  default     = "10.0.0.0/16"
}

variable "private_subnets" {
  type        = list(string)
  description = "A list of private subnets inside the VPC. Default is [\"10.0.1.0/24\", \"10.0.2.0/24\"]"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnets" {
  type        = list(string)
  description = "A list of public subnets inside the VPC. Default is [\"10.0.1.0/24\", \"10.0.2.0/24\"]"
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}
