variable "owner" {
  type        = string
  description = "Value used as prefix to object name (also tag Name)."
}

variable "access_public_ip" {
  type        = string
  description = "Public IP access to Application LoadBalancer and Bastion host over SSH."
}

variable "network_address_space" {
  type        = string
  description = "VPC network address space"
  default     = "10.0.0.0/16"
}
variable "subnetA_prv_address_space" {
  type        = string
  description = "Private subnet A address space"
  default     = "10.0.1.0/24"
}
variable "subnetB_prv_address_space" {
  type        = string
  description = "Private subnet B address space"
  default     = "10.0.2.0/24"
}
variable "subnetA_public_address_space" {
  type        = string
  description = "Public subnet A address space"
  default     = "10.0.11.0/24"
}
variable "subnetB_public_address_space" {
  type        = string
  description = "Public subnet B address space"
  default     = "10.0.12.0/24"
}

variable "subnet_idxs" {
  type        = map(any)
  description = "Subnet indexes keypair"
  default = {
    "a" = 0,
    "b" = 1
  }
}