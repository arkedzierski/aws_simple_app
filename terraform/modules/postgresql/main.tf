##################################################################################
# RDS postgres
##################################################################################

resource "aws_db_subnet_group" "db_sbnet_grp" {
  name = "${var.owner}-db-sbnet-grp"
  subnet_ids = var.subnet_ids
}

resource "aws_db_instance" "db" {
  allocated_storage = var.storage
  apply_immediately = true
  db_subnet_group_name = aws_db_subnet_group.db_sbnet_grp.name
  engine = "postgres"
  engine_version = var.engine_version
  iam_database_authentication_enabled = true
  identifier = var.db_name
  instance_class = var.db_class
  password = var.db_password
  publicly_accessible = false
  vpc_security_group_ids = var.security_group_ids
  skip_final_snapshot = true
  username = var.db_user
}

