variable "owner" {
  type        = string
  description = "Value used as prefix to object name (also tag Name)."
}

variable "image_id" {
  type        = string
  description = "The id of the machine image (AMI) to use for the server."
}

variable "subnet_id" {
  type        = string
  description = "Subnet id for aws_instance"
}

variable "security_group_ids" {
  type        = list(string)
  description = "List of security groups id for aws_instance"
}

variable "key_name" {
  type        = string
  description = "Key Pairs name"
}

variable "instance_type" {
  type        = string
  description = "Set EC2 instance type. Default t2.nano"
  default     = "t2.nano"
}

variable "enable_public_ip" {
  type        = bool
  description = "Enable public IP for EC2 instance. Default false"
  default     = false
}

variable "name" {
  type        = string
  description = "subfix for instance name. Default empty string"
  default     = ""
}

