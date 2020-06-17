provider "aws" {
  region = var.region
}

resource "aws_vpc" "vpc" {
  tags = {
    Name = "MartynSidaway"
    Owner = "Martyn Sidaway"
    Project = "Tech Test"
  }
  cidr_block           = var.vpc-cidr
  enable_dns_hostnames = true
}

resource "aws_subnet" "public-subnet" {
  tags = {
    Name = "MartynSidaway"
    Owner = "Martyn Sidaway"
    Project = "Tech Test"
  }

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet-cidr-public
  availability_zone = "${var.region}a"
}

resource "aws_route_table" "public-subnet-route-table" {
  tags = {
    Name = "MartynSidaway"
    Owner = "Martyn Sidaway"
    Project = "Tech Test"
  }
  vpc_id = aws_vpc.vpc.id
}

resource "aws_internet_gateway" "igw" {
  tags = {
    Name = "MartynSidaway"
    Owner = "Martyn Sidaway"
    Project = "Tech Test"
  }
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route" "public-subnet-route" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
  route_table_id         = aws_route_table.public-subnet-route-table.id
}

resource "aws_route_table_association" "public-subnet-route-table-association" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-subnet-route-table.id
}

resource "aws_key_pair" "web" {  tags = {
    Name = "MartynSidaway"
    Owner = "Martyn Sidaway"
    Project = "Tech Test"
  }
  public_key = file(pathexpand(var.public_key))
}

resource "aws_instance" "web-instance" {
  tags = {
    Name = "MartynSidaway"
    Owner = "Martyn Sidaway"
    Project = "Tech Test"
  }
  ami                         = "ami-cdbfa4ab"
  instance_type               = "t2.small"
  vpc_security_group_ids      = [aws_security_group.web-instance-security-group.id]
  subnet_id                   = aws_subnet.public-subnet.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.web.key_name
  user_data                   = <<EOF
#!/bin/sh
yum install -y nginx
service nginx start
EOF

}

resource "aws_security_group" "web-instance-security-group" {
  tags = {
    Name = "MartynSidaway"
    Owner = "Martyn Sidaway"
    Project = "Tech Test"
  }
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "web_domain" {
  value = aws_instance.web-instance.public_dns
}

