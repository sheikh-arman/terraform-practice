provider "aws" {
  region="us-east-2"
}

# Create a VPC
resource "aws_vpc" "bastion_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "bastion-vpc"
  }
}


#create internet gateway and attach vpc
resource "aws_internet_gateway" "bastion_gw" {
  vpc_id = aws_vpc.bastion_vpc.id

  tags = {
    Name = "bastion-gatewa"
  }
}

#create public subnet
resource "aws_subnet" "bastion_public_subnet" {
  vpc_id            = aws_vpc.bastion_vpc.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true  # Enables automatic public IP assignment
  tags = {
    Name = "public-subnet"
  }
}

#create private subnet
resource "aws_subnet" "bastion_private_subnet" {
  vpc_id            = aws_vpc.bastion_vpc.id
  cidr_block        = "10.0.2.0/24"
  tags = {
    Name = "private-subnet"
  }
}

#create route table
resource "aws_route_table" "bastion_rt" {
  vpc_id = aws_vpc.bastion_vpc.id

  route {
    cidr_block = "0.0.0.0/0" # Route all outbound traffic to the internet
    gateway_id = aws_internet_gateway.bastion_gw.id
  }

  tags = {
    Name = "bastion_route"
  }
}
#create subnet association to route table
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.bastion_public_subnet.id
  route_table_id = aws_route_table.bastion_rt.id
}
resource "aws_eip" "nat_eip" {}
#create nat gatway for private subnet, but attach on public subnet
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.bastion_public_subnet.id

  tags = {
    Name = "nat-gateway"
  }
}
#create route table for nat
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.bastion_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.bastion_private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

# create security group
# resource "aws_security_group" "bastion_sg" {
#     vpc_id = aws_vpc.bastion_vpc.id
#
#     ingress {
#         from_port   = 22
#         to_port     = 22
#         protocol    = "tcp"
#         cidr_blocks = ["YOUR_IP/32"]  # Restrict to your IP
#     }
#
#     egress {
#         from_port   = 0
#         to_port     = 0
#         protocol    = "-1"
#         cidr_blocks = ["0.0.0.0/0"]
#     }
#
#     tags = {
#         Name = "bastion-sg"
#     }
# }
#create ec2 bastion server
resource "aws_instance" "ec2_bastion_server" {
  ami = ""
  instance_type = "t2.micro"
  associate_public_ip_address = true
  subnet_id     = aws_subnet.bastion_public_subnet.id
  key_name = "your-key"  # Use an existing SSH key pair
  tags = {
    Name= "bastion Host"
  }
}

#create ec2 private server
resource "aws_instance" "ec2_private_server" {
  ami = ""
  subnet_id     = aws_subnet.bastion_private_subnet.id
  key_name = "your-key"  # Use an existing SSH key pair
  instance_type = "t2.micro"
  tags = {
    Name= "Private Host"
  }
}