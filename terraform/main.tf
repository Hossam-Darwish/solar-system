
data "aws_availability_zones" "available" {
  state = "available"
}

#  VPC
resource "aws_vpc" "app_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "solar-system-vpc" }
}

#  Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  tags                    = { Name = "solar-system-public-subnet" }
}

#   Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.app_vpc.id
  tags   = { Name = "solar-system-igw" }
}

#   Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "solar-system-public-rt" }
}

#   Route Table Association
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

#   Security Group
resource "aws_security_group" "app_sg" {
  name        = "solar-system-sg"
  description = "Allow HTTP and SSH"
  vpc_id      = aws_vpc.app_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "solar-system-sg" }
}

#   EC2 Instance
resource "aws_instance" "app_instance" {
  ami                    = "ami-01a612f2c60d80101"
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  key_name               = var.app_key_name
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  tags = { Name = "solar-system-ec2" }

  user_data = <<-EOF
              #!/bin/bash
              set -ex
              sudo yum update -y
              sudo yum install -y git docker
              sudo systemctl start docker
              sudo systemctl enable docker 
              docker pull hoss1212/solar-system:23d87cfd77d23f5ccba975f016dee0427f506bf2
              docker run -d -p 3000:3000 \
                -e MONGO_URI='mongodb+srv://supercluster.d83jj.mongodb.net/superData' \
                -e MONGO_USERNAME='superuser' \
                -e MONGO_PASSWORD='SuperPassword' \
                hoss1212/solar-system:23d87cfd77d23f5ccba975f016dee0427f506bf2
              EOF
}

resource "aws_eip" "app_eip" {
  domain = "vpc"
  tags = {
    Name = "solar-system-eip"
  }
}

resource "aws_eip_association" "app_eip_assoc" {
  instance_id   = aws_instance.app_instance.id
  allocation_id = aws_eip.app_eip.id
}


