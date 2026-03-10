provider "aws" {
  region = "us-west-1"
}

resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  tags = {
    Name = "ServerB-VPC"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr_block

  tags = {
    Name = "ServerB-Subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidr_block

  tags = {
    Name = "ServerB-Private-Subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "ServerB-IGW"
  }
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}


resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id = aws_subnet.public_subnet.id

  tags = {
    Name = "ServerB-NAT-Gateway"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block =  "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id    
  }

    tags = {
        Name = "ServerB-Public-RT"
    }   
}



resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "ServerB-Private-RT"
  }
}

# resource "aws_route" "peering_route" {
#   count                     = var.peering_connection_id != "" ? 1 : 0
#   route_table_id            = aws_route_table.private_rt.id
#   destination_cidr_block    = var.cidr_block_servera
#   vpc_peering_connection_id = var.peering_connection_id
# }

resource "aws_route_table_association" "public_subnet_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_subnet_assoc" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_security_group" "sg1" {
  name        = "sg1"
  description = "Security group for EC2 instance"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.cidr_block_servera]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "ec2_instance" {
    ami           = data.aws_ami.amazon_linux.id
    instance_type = "t2.micro"
    subnet_id     = aws_subnet.private_subnet.id
    vpc_security_group_ids = [aws_security_group.sg1.id]

    tags = {
        Name = "ServerB-EC2-Instance"
    }
}