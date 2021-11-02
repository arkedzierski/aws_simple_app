data "template_file" "sql_db_create" {
  template = file("${path.module}/templates/create_db.tmpl")

  vars = {
    rds_dbname = var.rds_dbname
    rds_username = var.rds_username
  }
}