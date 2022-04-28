resource "aws_vpc" "us-east-1_vpc" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "us-east-1_vpc"
  }
}

resource "aws_subnet" "us-east-1a-public_subnet" {
  vpc_id                  = aws_vpc.us-east-1_vpc.id
  cidr_block              = "10.10.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "us-east-1a-public_subnet"
  }
}

resource "aws_internet_gateway" "us-east-1_internet_gateway" {
  vpc_id = aws_vpc.us-east-1_vpc.id

  tags = {
    Name = "us-east-1_igw"
  }
}

resource "aws_route_table" "us-east-1a-public-subnet_rt" {
  vpc_id = aws_vpc.us-east-1_vpc.id
  tags = {
    Name = "us-east-1a-public-subnet_rt"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.us-east-1a-public-subnet_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.us-east-1_internet_gateway.id
}

resource "aws_route_table_association" "rt_subnet_association" {
  subnet_id      = aws_subnet.us-east-1a-public_subnet.id
  route_table_id = aws_route_table.us-east-1a-public-subnet_rt.id
}

resource "aws_security_group" "public_security_group" {
  name        = "public_security_group"
  description = "public security group"
  vpc_id      = aws_vpc.us-east-1_vpc.id

  tags = {
    Name = "public_security_group"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" #tf equivalent to all....
    cidr_blocks = ["0.0.0.0/0"]
  }
}


