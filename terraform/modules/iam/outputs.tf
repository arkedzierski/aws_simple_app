##################################################################################
# OUTPUT
##################################################################################

output "role_access_to_db_arn" {
  value = aws_iam_role.role-access-to-db.arn
}

output "role_access_to_s3_bucket_arn" {
  value = aws_iam_role.role-access-to-s3-bucket.arn
}

output "role_task_exec_arn" {
  value = aws_iam_role.role-task-exec.arn
}