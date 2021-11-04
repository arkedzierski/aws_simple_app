##################################################################################
# VPC
##################################################################################

# Infra
resource "aws_vpc" "vpc" {
  cidr_block = var.network_address_space
  enable_dns_hostnames = true

  tags = { Name = "${var.owner}-vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = { Name = "${var.owner}-igw" }

}

resource "aws_subnet" "subnetA-prv" {
  cidr_block              = var.subnetA_prv_address_space
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = { Name = "${var.owner}-subnetA-prv" }

}

resource "aws_subnet" "subnetB-prv" {
  cidr_block              = var.subnetB_prv_address_space
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = { Name = "${var.owner}-subnetB-prv" }

}

resource "aws_subnet" "subnetA-public" {
  cidr_block              = var.subnetA_public_address_space
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = { Name = "${var.owner}-subnetA-public" }

}

resource "aws_subnet" "subnetB-public" {
  cidr_block              = var.subnetB_public_address_space
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = { Name = "${var.owner}-subnetB-public" }

}

resource "aws_eip" "eip" {
  vpc = true
  tags = { Name = "${var.owner}-eip" }
}

resource "aws_nat_gateway" "nat-sb1" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.subnetA-public.id
  tags = { Name = "${var.owner}-nat-sb1" }
  depends_on = [aws_internet_gateway.igw]
}

# ROUTING #
resource "aws_route_table" "rtb-prv" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-sb1.id
  }

  tags = { Name = "${var.owner}-rtb-prv" }

}

resource "aws_route_table_association" "rta-subnetA-prv" {
  subnet_id      = aws_subnet.subnetA-prv.id
  route_table_id = aws_route_table.rtb-prv.id
}

resource "aws_route_table_association" "rta-subnetB-prv" {
  subnet_id      = aws_subnet.subnetB-prv.id
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

resource "aws_route_table_association" "rta-subnetA-public" {
  subnet_id      = aws_subnet.subnetA-public.id
  route_table_id = aws_route_table.rtb-public.id
}

resource "aws_route_table_association" "rta-subnetB-public" {
  subnet_id      = aws_subnet.subnetB-public.id
  route_table_id = aws_route_table.rtb-public.id
}

