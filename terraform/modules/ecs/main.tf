##################################################################################
# ECS
##################################################################################

resource "aws_ecs_cluster" "cluster-fargate" {
  name = "${var.owner}-cluster-fargate"
}

# Task definition s3
resource "aws_ecs_task_definition" "td-fargate-app-s3" {
  family = "${var.owner}-td-fargate-app-s3"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = 256
  memory = 512
  execution_role_arn = var.role_task_exec_arn
  task_role_arn = var.role_access_to_s3_bucket_arn
  container_definitions = <<EOT
      [${data.template_file.fargate-app-s3.rendered}]
EOT
}

# Task definition db
resource "aws_ecs_task_definition" "td-fargate-app-db" {
  family = "${var.owner}-td-fargate-app-db"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = 256
  memory = 512
  execution_role_arn = var.role_task_exec_arn
  task_role_arn = var.role_access_to_db_arn
  container_definitions = <<EOT
      [${data.template_file.fargate-app-db.rendered}, ${data.template_file.fargate-app-nginx.rendered}]
EOT
}

# ECS service db
resource "aws_ecs_service" "service-fargate-db" {
 name = "${var.owner}-service-fargate-db"
 cluster = aws_ecs_cluster.cluster-fargate.id
 task_definition = aws_ecs_task_definition.td-fargate-app-db.arn
 desired_count = 2
 deployment_minimum_healthy_percent = 50
 deployment_maximum_percent = 200
 launch_type = "FARGATE"
 scheduling_strategy = "REPLICA"
 
 network_configuration {
   security_groups  = var.container_secgrp_ids
   subnets          = var.container_network_ids
   assign_public_ip = false
 }
 
 load_balancer {
   target_group_arn = aws_alb_target_group.tg-fargate-app-db.arn
   container_name = "${var.owner}-container-fargate-app-db-nginx"
   container_port = 80
 }
 
 lifecycle {
   ignore_changes = [task_definition, desired_count]
 }
}

# ECS service s3
resource "aws_ecs_service" "service-fargate-s3" {
 name = "${var.owner}-service-fargate-s3"
 cluster = aws_ecs_cluster.cluster-fargate.id
 task_definition = aws_ecs_task_definition.td-fargate-app-s3.arn
 desired_count = 2
 deployment_minimum_healthy_percent = 50
 deployment_maximum_percent = 200
 launch_type = "FARGATE"
 scheduling_strategy = "REPLICA"
 
 network_configuration {
   security_groups  = var.container_secgrp_ids
   subnets          = var.container_network_ids
   assign_public_ip = false
 }
 
 load_balancer {
   target_group_arn = aws_alb_target_group.tg-fargate-app-s3.arn
   container_name = "${var.owner}-container-fargate-app-s3"
   container_port = 5000
 }
 
 lifecycle {
   ignore_changes = [task_definition, desired_count]
 }
}

# TARGET GROUP
resource "aws_alb_target_group" "tg-fargate-app-s3" {
  name = "${var.owner}-tg-fargate-app-s3"
  port = 5000
  protocol = "HTTP"
  vpc_id  = var.vpc_id
  target_type = "ip"
 
  health_check {
   healthy_threshold = "3"
   interval = "30"
   protocol = "HTTP"
   port = 5000
   matcher = "200"
   timeout = "3"
   path = "/hc"
   unhealthy_threshold = "2"
  }
}

resource "aws_alb_target_group" "tg-fargate-app-db" {
  name = "${var.owner}-tg-fargate-app-db"
  port = 80
  protocol = "HTTP"
  vpc_id  = var.vpc_id
  target_type = "ip"
 
  health_check {
   healthy_threshold = "3"
   interval = "30"
   protocol = "HTTP"
   port = 80
   matcher = "200"
   timeout = "3"
   path = "/hc"
   unhealthy_threshold = "2"
  }
}


# LOADBALANCER FOR ECS
resource "aws_lb" "lb-apps" {
  name = "${var.owner}-alb-apps"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.loadbalancer_secgrp_ids
  subnets            = var.loadbalancer_network_ids
 
  enable_deletion_protection = false
}
 
 resource "aws_alb_listener" "alb-list-http" {
  load_balancer_arn = aws_lb.lb-apps.arn
  port              = 80
  protocol          = "HTTP"
 
  default_action {
    target_group_arn = aws_alb_target_group.tg-fargate-app-db.arn
    type             = "forward"
  }
}

resource "aws_lb_listener_rule" "static" {
  listener_arn = aws_alb_listener.alb-list-http.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.tg-fargate-app-s3.arn
  }

  condition {
    path_pattern {
      values = ["/s3"]
    }
  }
}
