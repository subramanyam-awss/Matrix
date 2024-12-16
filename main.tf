provider "aws" {
 region = "us-east-1" 
}
resource "aws_instance" "demo-server" {
  ami = "ami-0e2c8caa4b6378d8c"
  instance_type = "t2.small"
  key_name = "dpo"
  vpc_security_group_ids = [aws_security_group.demo-sg.id]
  subnet_id = aws_subnet.dpw-public_subnet_01.id
  for_each = toset(["Jenkins-Master", "Jenkins-Slave", "Ansible"])
  tags = {
    name = "${each.key}"
  }
}
resource "aws_security_group" "demo-sg" {
    name = "demo-sg"
    vpc_id = aws_vpc.dpw-vpc.id

    ingress {
        description = "ssh-service"
        from_port = "22"
        to_port = "22"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "Jenkins-GUI-Access"
        from_port = "8080"
        to_port = "8080"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = "0"
        to_port = "0"
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
   tags = {
    name = "demo-server-sg"
   } 
}
resource "aws_vpc" "dpw-vpc" {
    cidr_block = "10.1.0.0/16"

    tags = {
      name = "dpw-vpc"
    }
  
}
resource "aws_subnet" "dpw-public_subnet_01" {
    vpc_id = aws_vpc.dpw-vpc.id
    cidr_block = "10.1.1.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "us-east-1a"

    tags = {
      name = "dpw-public_subnet_01"
    }
  
}
resource "aws_internet_gateway" "dpw-igw" {
    vpc_id = aws_vpc.dpw-vpc.id

    tags = {
      name = "dpw-igw"
    }
}
resource "aws_route_table" "dpw-public-rt" {
    vpc_id = aws_vpc.dpw-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.dpw-igw.id
    }
    tags = {
      name = "dpw-public-rt"
    }
  
}
resource "aws_route_table_association" "dpw-rta-public-subnet-1" {
    subnet_id = aws_subnet.dpw-public_subnet_01.id
    route_table_id = aws_route_table.dpw-public-rt.id
}