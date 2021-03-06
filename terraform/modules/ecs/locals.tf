##################################################################################
# LOCALS
##################################################################################

locals {

  fargate-app-s3 = templatefile("${path.module}/templates/container_definitions.tmpl", {
    container_name          = "${var.owner}-container-fargate-app-s3"
    container_image         = "${var.container_image_prefix}s3:latest"
    container_essential     = true
    container_env_list      = <<EOT
    [
        {
            "name": "BUCKET_NAME",
            "value": "${var.s3_bucket_name}"
        },
        {
            "name": "LB_ENDPOINT",
            "value": "${aws_service_discovery_service.flaskdb.name}.${aws_service_discovery_private_dns_namespace.servcediscovery_private_dns.name}"
        },
        {
            "name": "FLASK_ENV",
            "value": "development"
        }
    ]
    EOT
    container_port          = 5000
    container_logs_group    = "/ecs/${var.owner}-fargate-apps-s3"
    container_logs_region   = "${var.cloudwatch_region}"
    container_stream_prefix = "ecs"
  })

  fargate-app-db = templatefile("${path.module}/templates/container_definitions.tmpl",
    {
      container_name          = "${var.owner}-container-fargate-app-db"
      container_image         = "${var.container_image_prefix}db:latest"
      container_essential     = true
      container_env_list      = <<EOT
      [
          {
              "name": "RDS_USER",
              "value": "${var.rds_username}"
          },
          {
              "name": "RDS_ENDPOINT",
              "value": "${var.rds_endpoint}"
          },
          {
              "name": "RDS_DBNAME",
              "value": "${var.rds_dbname}"
          },
          {
              "name": "FLASK_ENV",
              "value": "development"
          }
      ]
      EOT
      container_port          = 5000
      container_logs_group    = "/ecs/${var.owner}-fargate-apps-db"
      container_logs_region   = "${var.cloudwatch_region}"
      container_stream_prefix = "ecs"
    }
  )

  fargate-app-nginx = templatefile("${path.module}/templates/container_definitions.tmpl",
    {
      container_name          = "${var.owner}-container-fargate-app-db-nginx"
      container_image         = "${var.container_image_prefix}nginx:latest"
      container_essential     = true
      container_env_list      = "[]"
      container_port          = 80
      container_logs_group    = "/ecs/${var.owner}-fargate-apps-db-nginx"
      container_logs_region   = "${var.cloudwatch_region}"
      container_stream_prefix = "ecs"
    }
  )
}