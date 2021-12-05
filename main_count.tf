provider "aws" {
  region = "us-east-1"

}

resource "aws_vpc" "my-vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    "Name" = "main-sravan-VPC"
  }

}

resource "aws_internet_gateway" "my-INTER-GATEway" {
  vpc_id = aws_vpc.my-vpc.id
  tags = {
    "Name" = "my_IGW"
  }

}

resource "aws_security_group" "webservers_sg" {
  name        = "allow_http"
  description = "Allow http inbound traffic"
  vpc_id      = aws_vpc.my-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Subnets : public
resource "aws_subnet" "public" {
  count                   = length(var.subnet_cidr)
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = element(var.subnet_cidr, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "Subnet-sravan-pub-${count.index + 1}"
  }
}


# Route table: attach Internet Gateway , creating route table 
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-INTER-GATEway.id
  }
  tags = {
    Name = "publicRouteTable"
  }
}

# Route table association with public subnets
resource "aws_route_table_association" "route_table_association" {
  count          = length(var.subnet_cidr)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public_rt.id
}





resource "aws_instance" "ec2-1" {
  count           = length(var.subnet_cidr)
  ami             = var.ami_name
  instance_type   = var.type
  security_groups = [aws_security_group.webservers_sg.id]
  subnet_id       = element(aws_subnet.public.*.id, count.index)
  availability_zone = element(var.azs, count.index)
  

  user_data = "${file("install.sh")}"



  tags = {
    "Name" = "demo-sravan${count.index}"
  }


}

