terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.81.0"
    }
  }
}
provider "aws" {
  region = "us-west-1"
  access_key = "AKIAZ3MGNK62RBZWMGU2"
  secret_key = "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"
}
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/24"
  tags = {
    Name="my_vpc"
  }
}
resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.0.0/25"
  availability_zone = "us-west-1a"
  map_public_ip_on_launch = true
  tags = {
    Name="public_subnet"
  }
}
resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.0.128/25"
  availability_zone = "us-west-1a"
  tags = {
    Name="private_subnet"
  }
}
resource "aws_internet_gateway" "my_gateway" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name="my_gateway"
  }
}
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name="my_route_table"
  }
}
resource "aws_route" "my_route" {
  route_table_id = aws_route_table.my_route_table.id
  gateway_id = aws_internet_gateway.my_gateway.id
  destination_cidr_block = "0.0.0.0/0"
}
resource "aws_route_table_association" "my_routetable_association" {
  route_table_id = aws_route_table.my_route_table.id
  subnet_id = aws_subnet.public_subnet.id
}
resource "aws_security_group" "my_security" {
  name = "my_security"
  vpc_id = aws_vpc.my_vpc.id
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name="my_security"
  }
}
data "aws_ami" "debian" {
  most_recent = true
  owners      = ["136693071363"]
  filter {
    name   = "name"
    values = ["debian-12-amd64-*"]
  }
}
resource "aws_instance" "new" {
  key_name = aws_key_pair.course.key_name
  ami =  data.aws_ami.debian.id
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.my_security.id]
  tags = {
    Name="new"
  }
}
