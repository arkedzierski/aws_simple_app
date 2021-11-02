##################################################################################
# RESOURCES
##################################################################################

#Random ID
resource "random_integer" "rand" {
  min = 10000
  max = 99999
}

# VPC #
module "vpc" {
  source = "./modules/vpc"

  owner = var.owner
  access_public_ip = var.access_public_ip
}

# IAM #
module "iam" {
  source = "./modules/iam"

  owner = var.owner
  s3_bucket_name = local.s3_bucket_name
  db_region = var.region
  db_resource_id = module.postgres.db_resource_id
  db_username = "ken"
}


# S3 Bucket #
module "s3-bucket" {
  source = "./modules/s3"

  owner = var.owner
  s3_bucket_name = local.s3_bucket_name
}

# RDS PostgreSQL
module "postgres" {
  source = "./modules/postgresql"

  owner = var.owner
  db_name = local.db_name
  db_master_password = var.db_password
  subnet_ids = [module.vpc.subnetA_prv_id, module.vpc.subnetB_prv_id ]
  security_group_ids = [module.vpc.secgrp_psql_id]
  rds_username = "ken"
  rds_dbname = "ec2"
  ec2_public_ip = module.ec2.instance_public_ip
  ec2_host_key = file(var.path_pair_key)
}

# EC2 #
module "ec2" {
  source = "./modules/ec2"

  owner = var.owner
  image_id = data.aws_ami.ubuntu.id
  subnet_id = module.vpc.subnetA_public_id
  security_group_ids = [module.vpc.secgrp_bastion_ssh_id, module.vpc.secgrp_ecs_id]
  key_name = var.key_name
  enable_public_ip = true
  name = "bastion"
}

# ECS CLUSTER #
module "ecs" {
  source = "./modules/ecs"

  owner = var.owner
  vpc_id = module.vpc.vpc_id
  role_access_to_db_arn = module.iam.role_access_to_db_arn
  role_access_to_s3_bucket_arn = module.iam.role_access_to_s3_bucket_arn
  role_task_exec_arn = module.iam.role_task_exec_arn
  container_image_prefix = var.container_image_prefix
  s3_bucket_name = local.s3_bucket_name
  rds_endpoint = module.postgres.db_instance_address
  rds_username = "ken"
  rds_dbname = "ec2"
  container_secgrp_ids = [module.vpc.secgrp_ecs_id]
  container_network_ids = [module.vpc.subnetA_prv_id, module.vpc.subnetB_prv_id]
  cloudwatch_region = var.region
  loadbalancer_secgrp_ids = [module.vpc.secgrp_lb_id]
  loadbalancer_network_ids = [module.vpc.subnetA_public_id, module.vpc.subnetB_public_id]
}