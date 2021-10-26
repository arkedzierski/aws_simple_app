##################################################################################
# RESOURCES
##################################################################################

#Random ID
resource "random_integer" "rand" {
  min = 10000
  max = 99999
}


# NETWORKING #
resource "aws_vpc" "vpc" {
  cidr_block = var.network_address_space

  tags = { Name = "${local.name_suffix}-vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = { Name = "${local.name_suffix}-igw" }

}

resource "aws_subnet" "subnet1-prv" {
  cidr_block              = var.subnet1_prv_address_space
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = { Name = "${local.name_suffix}-subnet1-prv" }

}

resource "aws_subnet" "subnet2-prv" {
  cidr_block              = var.subnet2_prv_address_space
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = { Name = "${local.name_suffix}-subnet2-prv" }

}

resource "aws_subnet" "subnet1-public" {
  cidr_block              = var.subnet1_public_address_space
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = { Name = "${local.name_suffix}-subnet1-public" }

}

resource "aws_subnet" "subnet2-public" {
  cidr_block              = var.subnet2_public_address_space
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = { Name = "${local.name_suffix}-subnet2-public" }

}

resource "aws_eip" "eip" {
  vpc = true
  tags = { Name = "${local.name_suffix}-eip" }
}

resource "aws_nat_gateway" "nat-sb1" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.subnet1-public.id
  tags = { Name = "${local.name_suffix}-nat-sb1" }
  depends_on = [aws_internet_gateway.igw]
}

# ROUTING #
resource "aws_route_table" "rtb-prv" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat-sb1.id
  }

  tags = { Name = "${local.name_suffix}-rtb-prv" }

}

resource "aws_route_table_association" "rta-subnet1-prv" {
  subnet_id      = aws_subnet.subnet1-prv.id
  route_table_id = aws_route_table.rtb-prv.id
}

resource "aws_route_table_association" "rta-subnet2-prv" {
  subnet_id      = aws_subnet.subnet2-prv.id
  route_table_id = aws_route_table.rtb-prv.id
}

resource "aws_route_table" "rtb-public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "${local.name_suffix}-rtb-public" }

}

resource "aws_route_table_association" "rta-subnet1-public" {
  subnet_id      = aws_subnet.subnet1-public.id
  route_table_id = aws_route_table.rtb-public.id
}

resource "aws_route_table_association" "rta-subnet2-public" {
  subnet_id      = aws_subnet.subnet2-public.id
  route_table_id = aws_route_table.rtb-public.id
}

# SECURITY GROUPS #

#LoadBalancer
resource "aws_security_group" "sg-lb" {
  name   = "${local.name_suffix}-sg-lb"
  vpc_id = aws_vpc.vpc.id
  tags = { Name = "${local.name_suffix}-sg-lb" }

  #Allow HTTP from VPN, NAT and local
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.ip-pgs-vpn, "${aws_eip.eip.public_ip}/32"]
  }

  #allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Containres
resource "aws_security_group" "sg-ecs" {
  name   = "${local.name_suffix}-sg-ecs-containers"
  vpc_id = aws_vpc.vpc.id
  tags = { Name = "${local.name_suffix}-sg-ecs" }

  #Allow HTTP from loadbalancer
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = ["${aws_security_group.sg-lb.id}"]
  }

  #allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#PostgreSQL
resource "aws_security_group" "sg_psql" {
  name   = "${local.name_suffix}-sg_psql"
  vpc_id = aws_vpc.vpc.id
  tags = { Name = "${local.name_suffix}-sg-psql" }

  #Allow HTTP from privte network
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = ["${aws_security_group.sg-ecs.id}"]
  }

  #allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Bastion 
resource "aws_security_group" "sg-ssh-bastion" {
  name   = "${local.name_suffix}-sg-ssh-bastion"
  vpc_id = aws_vpc.vpc.id
  tags = { Name = "${local.name_suffix}-ssh-bastion" }

  # SSH access from VPN
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ip-pgs-vpn]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# IAM #

# IAM Access to S3
resource "aws_iam_role" "role-access-to-s3-bucket" {
  name = "${local.name_suffix}-role-access-to-s3-bucket"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "instanceprofile-bucket-s3" {
  name = "${local.name_suffix}-instanceprofile-bucket-s3"
  role = aws_iam_role.role-access-to-s3-bucket.name
}

resource "aws_iam_role_policy" "policy-access-to-s3-bucket" {
  name = "${local.name_suffix}-policy-access-to-s3-bucket"
  role = aws_iam_role.role-access-to-s3-bucket.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::${local.s3_bucket_name}",
                "arn:aws:s3:::${local.s3_bucket_name}/*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "policy-sts-allow-get-token" {
  name = "${local.name_suffix}-policy-sts-allow-get-token"
  role = aws_iam_role.role-access-to-s3-bucket.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "sts:GetSessionToken",
                "sts:GetFederationToken"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}


# IAM Access do RDS
resource "aws_iam_role" "role-access-to-db-ken" {
  name = "${local.name_suffix}-role-access-to-db-ken"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "instanceprofile-rds" {
  name = "${local.name_suffix}-instanceprofile-rds"
  role = aws_iam_role.role-access-to-db-ken.name
}

resource "aws_iam_role_policy" "policy-access-to-db-ken" {
  name = "${local.name_suffix}-policy-access-to-db-ken"
  role = aws_iam_role.role-access-to-db-ken.name
  depends_on = [
    aws_db_instance.db
  ]

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "rds-db:connect",
            "Resource": "arn:aws:rds-db:${var.region}:${data.aws_caller_identity.current.account_id}:dbuser:${aws_db_instance.db.resource_id}/ken"
        }
    ]
}
EOF
}

# IAM ECS exec instance role
resource "aws_iam_role" "role-task-exec" {
  name = "${local.name_suffix}-role-task-exec"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "instanceprofile-task-exec" {
  name = "${local.name_suffix}-instanceprofile-task-exec"
  role = aws_iam_role.role-task-exec.name
}

resource "aws_iam_role_policy" "policy-ssm-allow-get-params" {
  name = "${local.name_suffix}-policy-ssm-allow-get-params"
  role = aws_iam_role.role-task-exec.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "ssm:GetParametersByPath",
                "ssm:GetParameters",
                "ssm:GetParameter"
            ],
            "Resource": "arn:aws:ssm:us-west-2:890769921003:parameter/akedzierski*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.role-task-exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# S3 Bucket #
resource "aws_s3_bucket" "s3-bucket" {
  bucket        = local.s3_bucket_name
  acl           = "private"
  force_destroy = true
  tags = { Name = "${local.name_suffix}-s3-bucket" }
}

resource "aws_s3_bucket_public_access_block" "s3-bucket" {
  bucket = aws_s3_bucket.s3-bucket.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true

}

# RDS PostgreSQL
resource "aws_db_subnet_group" "db_sbnet_grp" {
  name = "${local.name_suffix}-db-sbnet-grp"
  subnet_ids = [aws_subnet.subnet1-prv.id, aws_subnet.subnet2-prv.id]
}

resource "aws_db_instance" "db" {
  allocated_storage = 10
  apply_immediately = true
  db_subnet_group_name = aws_db_subnet_group.db_sbnet_grp.name
  engine = "postgres"
  engine_version = "12.8"
  iam_database_authentication_enabled = true
  identifier = local.db_name
  instance_class = "db.t2.micro"
  password = var.postgres_pass
  publicly_accessible = false
  vpc_security_group_ids = [ "${aws_security_group.sg_psql.id}" ]
  skip_final_snapshot = true
  username = "postgres"
}

# EC2 #
# EC2 bastion
resource "aws_instance" "web" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.nano"
  associate_public_ip_address = true
  key_name = var.key_name
  security_groups  = ["${aws_security_group.sg-ecs.id}", "${aws_security_group.sg-ssh-bastion.id}"]
  subnet_id = aws_subnet.subnet1-public.id
  tags = { Name = "${local.name_suffix}-ec2-bastion" }
}


# ECS CLUSTER #
resource "aws_ecs_cluster" "cluster-fargate" {
  name = "${local.name_suffix}-cluster-fargate"
}

# Task definition s3
resource "aws_ecs_task_definition" "td-fargate-app-s3" {
  family = "${local.name_suffix}-td-fargate-app-s3"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = 256
  memory = 512
  execution_role_arn = aws_iam_role.role-task-exec.arn
  task_role_arn = aws_iam_role.role-access-to-s3-bucket.arn
  container_definitions = jsonencode([{
    name        = "${local.name_suffix}-container-fargate-app-s3"
    image       = "${var.container_image_prefix}s3:latest"
    essential   = true
    environment = [
      {
          "name" = "BUCKET_NAME",
          "value" = "${local.s3_bucket_name}"
      },
      {
          "name" = "LB_ENDPOINT",
          "value" = "${aws_lb.lb-apps.dns_name}"
      },
      {
          "name" = "FLASK_ENV",
          "value" = "development"
      }
    ],
    "portMappings" = [{
      protocol      = "tcp",
      containerPort = 5000,
      hostPort      = 5000
    }]
    "logConfiguration": {
      "logDriver" = "awslogs",
      "options" = {
        "awslogs-group" = "${var.cloudwatch_group}-s3",
        "awslogs-region" = "${var.region}",
        "awslogs-stream-prefix" = "ecs"
        }
      }
  }])
}

# Task definition db
resource "aws_ecs_task_definition" "td-fargate-app-db" {
  family = "${local.name_suffix}-td-fargate-app-db"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = 256
  memory = 512
  execution_role_arn = aws_iam_role.role-task-exec.arn
  task_role_arn = aws_iam_role.role-access-to-db-ken.arn
  container_definitions = jsonencode([
    {
      name        = "${local.name_suffix}-container-fargate-app-db"
      image       = "${var.container_image_prefix}db:latest"
      essential   = true
      environment = [
        {
            "name" = "RDS_USR",
            "value" = "ken"
        },
        {
            "name" = "RDS_ENDPOINT",
            "value" = "${aws_db_instance.db.endpoint}"
        },
        {
            "name" = "RDS_DBNAME",
            "value" = "ec2"
        },
        {
            "name" = "FLASK_ENV",
            "value" = "development"
        }
      ],
      "portMappings" = [
        {
          protocol = "tcp",
          containerPort = 5000,
          hostPort = 5000
        }
      ],
      "logConfiguration": {
        "logDriver" = "awslogs",
        "options" = {
          "awslogs-group" = "${var.cloudwatch_group}-db",
          "awslogs-region" = "${var.region}",
          "awslogs-stream-prefix" = "ecs"
          }
      }
    },
    {
      name        = "${local.name_suffix}-container-fargate-app-db-ngnix"
      image       = "${var.container_image_prefix}nginx:latest"
      essential   = true
      "portMappings" = [
        {
          protocol = "tcp",
          containerPort = 80,
          hostPort = 80
        }
      ],
      "logConfiguration": {
        "logDriver" = "awslogs",
        "options" = {
          "awslogs-group" = "${var.cloudwatch_group}-db-ngnix",
          "awslogs-region" = "${var.region}",
          "awslogs-stream-prefix" = "ecs"
          }
      }
    }
  ])
}

# ECS service db
resource "aws_ecs_service" "service-fargate-db" {
 name = "${local.name_suffix}-service-fargate-db"
 cluster = aws_ecs_cluster.cluster-fargate.id
 task_definition = aws_ecs_task_definition.td-fargate-app-db.arn
 desired_count = 2
 deployment_minimum_healthy_percent = 50
 deployment_maximum_percent = 200
 launch_type = "FARGATE"
 scheduling_strategy = "REPLICA"
 
 network_configuration {
   security_groups  = ["${aws_security_group.sg-ecs.id}"]
   subnets          = ["${aws_subnet.subnet1-prv.id}", "${aws_subnet.subnet2-prv.id}"]
   assign_public_ip = false
 }
 
 load_balancer {
   target_group_arn = aws_alb_target_group.tg-fargate-app-db.arn
   container_name = "${local.name_suffix}-container-fargate-app-db-ngnix"
   container_port = 80
 }
 
 lifecycle {
   ignore_changes = [task_definition, desired_count]
 }
}

# ECS service s3
resource "aws_ecs_service" "service-fargate-s3" {
 name = "${local.name_suffix}-service-fargate-s3"
 cluster = aws_ecs_cluster.cluster-fargate.id
 task_definition = aws_ecs_task_definition.td-fargate-app-s3.arn
 desired_count = 2
 deployment_minimum_healthy_percent = 50
 deployment_maximum_percent = 200
 launch_type = "FARGATE"
 scheduling_strategy = "REPLICA"
 
 network_configuration {
   security_groups  = ["${aws_security_group.sg-ecs.id}"]
   subnets          = ["${aws_subnet.subnet1-prv.id}", "${aws_subnet.subnet2-prv.id}"]
   assign_public_ip = false
 }
 
 load_balancer {
   target_group_arn = aws_alb_target_group.tg-fargate-app-s3.arn
   container_name = "${local.name_suffix}-container-fargate-app-s3"
   container_port = 5000
 }
 
 lifecycle {
   ignore_changes = [task_definition, desired_count]
 }
}

# TARGET GROUP
resource "aws_alb_target_group" "tg-fargate-app-s3" {
  name = "${local.name_suffix}-tg-fargate-app-s3"
  port = 5000
  protocol = "HTTP"
  vpc_id  = aws_vpc.vpc.id
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
  name = "${local.name_suffix}-tg-fargate-app-db"
  port = 80
  protocol = "HTTP"
  vpc_id  = aws_vpc.vpc.id
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
  name = "${local.name_suffix}-alb-apps"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.sg-lb.id}"]
  subnets            = ["${aws_subnet.subnet1-public.id}", "${aws_subnet.subnet2-public.id}"]
 
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
      values = ["/s3/*"]
    }
  }
}