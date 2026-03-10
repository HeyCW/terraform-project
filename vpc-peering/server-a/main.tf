provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "west"
  region = "us-west-1"
}

resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  tags = {
    Name = "ServerA-VPC"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr_block

  tags = {
    Name = "ServerA-Subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidr_block

  tags = {
    Name = "ServerA-Private-Subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "ServerA-IGW"
  }
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id = aws_subnet.public_subnet.id

  tags = {
    Name = "ServerA-NAT-Gateway"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block =  "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id    
  }

  route {
    cidr_block = var.cidr_block_serverb
    vpc_peering_connection_id = aws_vpc_peering_connection.peering_connection.id
  }

    tags = {
        Name = "ServerA-Public-RT"
    }   
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block =  "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id    
  }

    tags = {
        Name = "ServerA-Private-RT"
    }   
}

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_vpc" "peer" {
  provider = aws.west
  tags = {
    Name = "ServerB-VPC"
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
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.sg1.id]
  associate_public_ip_address = true

  tags = {
    Name = "ServerA-EC2"
  }
}

resource "aws_vpc_peering_connection" "peering_connection" {
    vpc_id        = aws_vpc.main.id
    peer_vpc_id   = data.aws_vpc.peer.id
    peer_region   = "us-west-1"

    tags = {
        Name = "ServerA-to-ServerB-Peering"
    }
}

resource "aws_vpc_peering_connection_accepter" "peer_accept" {
  provider                  = aws.west
  vpc_peering_connection_id = aws_vpc_peering_connection.peering_connection.id
  auto_accept               = true

  tags = {
    Name = "ServerB-Accept-Peering"
  }
}