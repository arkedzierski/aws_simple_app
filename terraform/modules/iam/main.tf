##################################################################################
# IAM
##################################################################################

# IAM Access to S3
resource "aws_iam_role" "role-access-to-s3-bucket" {
  name                = "${var.owner}-role-access-to-s3-bucket"
  assume_role_policy  = data.aws_iam_policy_document.ecs_instance-assume-role-policy.json
  managed_policy_arns = [aws_iam_policy.policy-access-to-s3-bucket.arn, aws_iam_policy.policy-sts-allow-get-token.arn]
}

resource "aws_iam_policy" "policy-access-to-s3-bucket" {
  name   = "${var.owner}-policy-access-to-s3-bucket"
  policy = data.aws_iam_policy_document.access-to-s3-bucket.json
}

resource "aws_iam_policy" "policy-sts-allow-get-token" {
  name   = "${var.owner}-policy-sts-allow-get-token"
  policy = data.aws_iam_policy_document.sts-allow-get-token.json
}


# IAM Access do RDS
resource "aws_iam_role" "role-access-to-db" {
  name                = "${var.owner}-role-access-to-db"
  assume_role_policy  = data.aws_iam_policy_document.ecs_instance-assume-role-policy.json
  managed_policy_arns = ["${aws_iam_policy.policy-access-to-db-ken.arn}"]
}

resource "aws_iam_policy" "policy-access-to-db-ken" {
  name   = "${var.owner}-policy-access-to-db-ken"
  policy = data.aws_iam_policy_document.access-to-db-ken.json
}

# IAM ECS exec instance role
resource "aws_iam_role" "role-task-exec" {
  name               = "${var.owner}-role-task-exec"
  assume_role_policy = data.aws_iam_policy_document.ecs_instance-assume-role-policy.json
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.role-task-exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
