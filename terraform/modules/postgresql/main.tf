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
  password = var.db_master_password
  publicly_accessible = false
  vpc_security_group_ids = var.security_group_ids
  skip_final_snapshot = true
  username = var.db_master_user
}

resource "null_resource" "create_db" {
  triggers = {
    public_ip = var.ec2_public_ip
  }

  connection {
    type  = "ssh"
    host  = var.ec2_public_ip
    user  = "ubuntu"
    port  = 22
    agent = true
    private_key = var.ec2_host_key
  }

  provisioner "file" {
    content = "${data.template_file.sql_db_create.rendered}"
    destination = "/tmp/create_db.sql"
  }

  // change permissions to executable and pipe its output into a new file
  provisioner "remote-exec" {
    inline = [
      "export PGPASSWORD=${var.db_master_password}",
      "psql -h ${aws_db_instance.db.address} -U ${var.db_master_user} -f /tmp/create_db.sql \"sslmode=require\""
    ]
  }

}