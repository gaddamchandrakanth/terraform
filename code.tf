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
-------------------------------------------------------------------------------------------------------------------------------
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/24"
  tags = {
    Name="my_vpc"
  }
}
resource "aws_subnet" "pub" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.0.0/25"
  map_public_ip_on_launch = true
  tags = {
    Name="pub"
  }
}
resource "aws_subnet" "prvt" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.0.128/25"
  tags = {
    Name="prvt"
  }
}
----------------------------------------------------------------------------------------------------------------------------------------
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
  -----------------------------------------------------------------------------------------------------------------
resource "aws_route" "my_route" {
  route_table_id = aws_route_table.my_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.my_gateway.id
}
resource "aws_route_table_association" "association" {
  route_table_id = aws_route_table.my_route_table.id
  subnet_id = aws_subnet.pub.id
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
    --------------------------------------------------------------------------------------------------------
variable "server" {
  default = [
    {name="one",ami="ami-0945610b37068d87a",type="t2.micro"},  #amazon
    {name="two",ami="ami-00271c85bf8a52b84",type="t2.micro"},  #ubuntu
    {name="three",ami="ami-0f7153f6999a5ef60",type="t2.micro"} #redhat
  ]
}
--------------------------------------------------------------------------------------------------------------------------
resource "aws_instance" "ubuntu_server" {
  ami = var.server[1].ami
  instance_type = var.server[1].type
  subnet_id = aws_subnet.prvt.id
  tags = {
    Name=var.server[1].name
  }
}
  -----------------------------------------------------------------------------------------------------------------------
locals {
  other={for inst in var.server:inst.name=>inst}
  ubuntu_server=local.other["two"]
}
resource "aws_instance" "multiple_server" {
  for_each = local.other
  ami = each.value.ami
  instance_type = each.value.type
  tags = {
    Name=each.key
  }
}
-------------------------------------------------------------------------------------------------------------------------------------------
resource "aws_launch_template" "my_template" {
  name = "my_template"
  image_id = local.ubuntu_server.ami
  instance_type = local.ubuntu_server.type
  vpc_security_group_ids = [aws_security_group.my_security.id]
}
resource "aws_autoscaling_group" "auto_scale" {
  max_size = 2
  min_size = 2
  desired_capacity = 2
  vpc_zone_identifier = [aws_subnet.pub.id]
  launch_template {
    id = aws_launch_template.my_template.id
    version = "$Latest"
  }
}
