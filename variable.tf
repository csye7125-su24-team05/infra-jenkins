variable "aws_access_key" {
  type = string
  sensitive = true
}

variable "aws_secret_key" {
  type = string
  sensitive = true
}

variable "region" {
  type = string
}

variable "vpc" {
  type = object({
    cidr_block = string
    tags       = map(string)
  })
}

variable "subnet" {
  type = object({
    cidr_block = string
    tags       = map(string)
  })
}

variable "igw" {
  type = object({
    tags = map(string)
  })
}

variable "rt" {
  type = object({
    tags = map(string)
  })
}

variable "route" {
  type = object({
    destination_cidr_block = string
  })
}

variable "sg" {
  type = object({
    name = string
    tags = map(string)
  })
}

variable "sg_rules" {
  type = map(object({
    type      = string
    from_port = number
    to_port   = number
    protocol  = string
    cidr_blocks = list(string)
  }))
}

variable "ami_data" {
  type = object({
    owners      = list(string)
    most_recent = bool
    filters = list(object({
      name   = string
      values = list(string)
    }))
  })
}

variable "ec2_instance" {
  type = object({
    instance_type = string
    tags          = map(string)
  })
}

variable "data_eip" {
  type = object({
    filters = list(object({
      name   = string
      values = list(string)
    }))
  })
}