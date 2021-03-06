##################################################################################
# VPC
##################################################################################

# Infra
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = { Name = "${var.owner}-vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags   = { Name = "${var.owner}-igw" }

}

resource "aws_subnet" "subnet-prvate" {
  for_each          = toset(var.private_subnets)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.key
  availability_zone = data.aws_availability_zones.available.names[index(var.private_subnets, each.key)]
  tags              = { Name = "${var.owner}-subnet-${data.aws_availability_zones.available.names[index(var.private_subnets, each.key)]}-prv" }
}

resource "aws_subnet" "subnet-public" {
  for_each          = toset(var.public_subnets)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.key
  availability_zone = data.aws_availability_zones.available.names[index(var.public_subnets, each.key)]
  tags              = { Name = "${var.owner}-subnet-${data.aws_availability_zones.available.names[index(var.public_subnets, each.key)]}-public" }
}

resource "aws_eip" "eip" {
  vpc  = true
  tags = { Name = "${var.owner}-eip" }
}

resource "aws_nat_gateway" "nat-sb1" {
  allocation_id = aws_eip.eip.id
  subnet_id     = (values(aws_subnet.subnet-public)[*].id)[0]
  tags          = { Name = "${var.owner}-nat-sb1" }
  depends_on    = [aws_internet_gateway.igw]
}

# ROUTING #
resource "aws_route_table" "rtb-prv" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-sb1.id
  }

  tags = { Name = "${var.owner}-rtb-prv" }

}

resource "aws_route_table_association" "rta-subnet-prvate" {
  for_each       = toset(var.private_subnets)
  subnet_id      = aws_subnet.subnet-prvate[each.key].id
  route_table_id = aws_route_table.rtb-prv.id
}

resource "aws_route_table" "rtb-public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "${var.owner}-rtb-public" }

}

resource "aws_route_table_association" "rta-subnet-public" {
  for_each       = toset(var.public_subnets)
  subnet_id      = aws_subnet.subnet-public[each.key].id
  route_table_id = aws_route_table.rtb-public.id
}
