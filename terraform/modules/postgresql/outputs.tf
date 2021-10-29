##################################################################################
# OUTPUT
##################################################################################

output "db_instance_id" {
  value = aws_db_instance.db.id
}

output "db_instance_address" {
  value = aws_db_instance.db.address
}