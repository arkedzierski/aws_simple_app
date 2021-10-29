##################################################################################
# LOCALS
##################################################################################

locals {
  s3_bucket_name = "${var.owner}-s3-${random_integer.rand.result}"
  db_name = "${var.owner}-db-${random_integer.rand.result}"
}
