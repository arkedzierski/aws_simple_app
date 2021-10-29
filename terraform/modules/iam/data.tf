##################################################################################
# DATA
##################################################################################

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "ecs_instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "access-to-s3-bucket" {
  statement {
    sid = "0"
    actions = [
        "s3:PutObject",
        "s3:GetObject",
        "s3:ListBucket"
    ]
    resources = [
        "arn:aws:s3:::${var.s3_bucket_name}",
        "arn:aws:s3:::${var.s3_bucket_name}/*"
    ]
  }
}

data "aws_iam_policy_document" "sts-allow-get-token" {
  statement {
    sid = "0"
    actions = [
        "sts:GetSessionToken",
        "sts:GetFederationToken"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "access-to-db-ken" {
  statement {
    sid = "0"
    actions = ["rds-db:connect"]
    resources = ["arn:aws:rds-db:${var.db_region}:${data.aws_caller_identity.current.account_id}:dbuser:${var.db_instance_id}/${var.db_username}"]
  }
}

