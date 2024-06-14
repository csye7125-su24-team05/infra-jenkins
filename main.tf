terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "jenkins-vpc" {
  cidr_block = var.vpc.cidr_block
  tags       = var.vpc.tags
}

# Create a Subnet
resource "aws_subnet" "jenkins-subnet" {
  vpc_id     = aws_vpc.jenkins-vpc.id
  cidr_block = var.subnet.cidr_block
  tags       = var.subnet.tags
}

# Create an Internet Gateway
resource "aws_internet_gateway" "jenkins-igw" {
  vpc_id = aws_vpc.jenkins-vpc.id
  tags   = var.igw.tags
}

# Create a Route Table
resource "aws_route_table" "jenkins-rt" {
  vpc_id = aws_vpc.jenkins-vpc.id
  tags   = var.rt.tags
}

# Create a Route
resource "aws_route" "jenkins-internetroute" {
  route_table_id         = aws_route_table.jenkins-rt.id
  destination_cidr_block = var.route.destination_cidr_block
  gateway_id             = aws_internet_gateway.jenkins-igw.id
}

# Associate the Route Table with the Subnet
resource "aws_route_table_association" "jenkins-rt-assoc" {
  subnet_id      = aws_subnet.jenkins-subnet.id
  route_table_id = aws_route_table.jenkins-rt.id
}

# Create a Security Group
resource "aws_security_group" "jenkins-sg" {
  name   = var.sg.name
  vpc_id = aws_vpc.jenkins-vpc.id
  tags   = var.sg.tags
}

# Create Security Group Rules
resource "aws_security_group_rule" "jenkins-sg-rule" {
  for_each = var.sg_rules
  type     = each.value.type
  from_port = each.value.from_port
  to_port   = each.value.to_port
  protocol  = each.value.protocol
  cidr_blocks = each.value.cidr_blocks
  security_group_id = aws_security_group.jenkins-sg.id
}

# Get the latest Ubuntu AMI
data "aws_ami" "ubuntu-ami" {

  most_recent = true

  dynamic "filter" {
    for_each = var.ami_data.filters
    content {
      name   = filter.value.name
      values = filter.value.values
    }
  }
  owners = ["891376931563"]
}

# Create an EC2 Instance
resource "aws_instance" "jenkins-instance" {
  ami                    = data.aws_ami.ubuntu-ami.id
  instance_type          = var.ec2_instance.instance_type
  subnet_id              = aws_subnet.jenkins-subnet.id
  vpc_security_group_ids = [aws_security_group.jenkins-sg.id]
  tags                   = var.ec2_instance.tags
}

data "aws_eip" "jenkins-eip" {
  dynamic "filter" {
    for_each = var.data_eip.filters
    content {
      name   = filter.value.name
      values = filter.value.values
    }

  }
}

resource "aws_eip_association" "jenkins-eip-assoc" {
  instance_id   = aws_instance.jenkins-instance.id
  allocation_id = data.aws_eip.jenkins-eip.id
}