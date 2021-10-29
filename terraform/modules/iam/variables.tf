variable "owner" {
    type = string
    description = "Value used as prefix to object name (also tag Name)."
}

variable "s3_bucket_name" {
    type = string
    description = "Name of S3 bucket to allow access role"
}

variable "db_region" {
    type = string
    description = "Region of DB instance to allow access role."
}

variable "db_instance_id" {
    type = string
    description = "ID of DB instance to allow access role."
}

variable "db_username" {
    type = string
    description = "Username of DB instance to allow access role."
}