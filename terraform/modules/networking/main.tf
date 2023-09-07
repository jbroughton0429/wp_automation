## VPC ##

resource "aws_vpc" "vpc" {
  cidr_block		= var.vpc_cidr
  enable_dns_hostnames  = true
  enable_dns_support    = true

  tags = { 
    Name = var.project
  }
}


## Public Subnet ##

resource "aws_subnet" "public_subnet" {
  vpc_id		  = aws_vpc.vpc.id
  count                   = length(var.public_subnets_cidr)
  cidr_block              = element(var.public_subnets_cidr, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = local.infra_tags
}


## Private Subnet ##

resource "aws_subnet" "private_subnet" {
  vpc_id		  = aws_vpc.vpc.id
  count			  = length(var.private_subnets_cidr)
  cidr_block	  	  = element(var.private_subnets_cidr, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = false

  tags = local.infra_tags
}


## Gateway ##

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id
  
  tags   = local.infra_tags
}


## Routes ##

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}

resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}


## Route Table - Private & Public ##

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id
  
  tags   = local.infra_tags
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags   = local.infra_tags
}


## Route Table Association ##

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets_cidr)
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets_cidr)
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = aws_route_table.private.id
}


## EIP ##

resource "aws_eip" "nat_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.ig]
}

## NAT Gateway ##

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.public_subnet.*.id, 0)
  depends_on    = [aws_internet_gateway.ig]

  tags = local.infra_tags
}


## Default Security Group ##

resource "aws_security_group" "default" {
  name        = "${var.project}-default-sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id      = aws_vpc.vpc.id
  depends_on  = [aws_vpc.vpc]

  /* Allow only ssh traffic from internet */
  ingress {
    from_port = "22"
    to_port   = "22"
    protocol  = "TCP"
    self      = true
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  /* Allow all outbound traffic to internet */
  egress {
    from_port        = "0"
    to_port          = "0"
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags =  local.infra_tags
}
