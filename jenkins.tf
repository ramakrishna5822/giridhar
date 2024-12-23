provider "aws" {

}

resource "aws_vpc" "test" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  tags = {
    Name = "${var.vpc_name}"
  }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.test.id
  tags = {
    Name = "${var.vpc_name}-igw"
  }

}


resource "aws_subnet" "subnets" {
  count                   = 3
  vpc_id                  = aws_vpc.test.id
  cidr_block              = element(var.cidr_block_subnets, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.vpc_name}-subnet${count.index + 1}"
  }

}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.test.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.vpc_name}-rt"
  }
}

resource "aws_route_table_association" "associate" {
  count          = 3
  route_table_id = aws_route_table.rt.id
  subnet_id      = element(aws_subnet.subnets.*.id, count.index)

}


resource "aws_security_group" "sg" {
  vpc_id      = aws_vpc.test.id
  description = "allow all rules"
  name        = "giri-security-group"
  tags = {
    Name = "${var.vpc_name}-sg"
  }
  ingress {
    to_port     = 0
    from_port   = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    to_port     = 0
    from_port   = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "instance" {
    count =1
    ami= var.ami
    instance_type = var.instance_type
    key_name = var.key_name
    vpc_security_group_ids = [aws_security_group.sg.id]
    subnet_id = aws_subnet.subnets[0].id
    associate_public_ip_address = true
    private_ip = element(var.private_ip,count.index)
    user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install java-17-amazon-corretto-headless -y
    sudo yum install wget -y
    sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum upgrade -y
sudo yum install jenkins -y
sudo systemctl daemon-reload
sudo systemctl start jenkins
 
  EOF

  tags ={
    Name = "${var.vpc_name}-server${count.index+1}"
  }
}