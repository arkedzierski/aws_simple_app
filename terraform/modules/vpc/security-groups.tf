##################################################################################
# SECURITY GROUPS
##################################################################################


#LoadBalancer
resource "aws_security_group" "sg-lb" {
  name   = "${var.owner}-sg-lb"
  vpc_id = aws_vpc.vpc.id
  tags = { Name = "${var.owner}-sg-lb" }

  #Allow HTTP from VPN, NAT and local
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.access_public_ip, "${aws_eip.eip.public_ip}/32"]
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
  name   = "${var.owner}-sg-ecs-containers"
  vpc_id = aws_vpc.vpc.id
  tags = { Name = "${var.owner}-sg-ecs" }

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
  name   = "${var.owner}-sg_psql"
  vpc_id = aws_vpc.vpc.id
  tags = { Name = "${var.owner}-sg-psql" }

  #Allow HTTP from privte network
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = ["${aws_security_group.sg-ecs.id}"]
  }

  # # Access from VPN
  # ingress {
  #   from_port   = 5432
  #   to_port     = 5432
  #   protocol    = "tcp"
  #   cidr_blocks = [var.access_public_ip]
  # }

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
  name   = "${var.owner}-sg-ssh-bastion"
  vpc_id = aws_vpc.vpc.id
  tags = { Name = "${var.owner}-ssh-bastion" }

  # SSH access from VPN
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.access_public_ip]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

