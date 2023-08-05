provider "aws" {
  region = "ap-south-1"  # Change to your desired AWS region
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public_subnet" {
  count = 2
  cidr_block = "10.0.${count.index + 1}.0/24"
  availability_zone = "ap-south-1"  # Change to your desired AZ
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_subnet" "private_subnet" {
  count = 2
  cidr_block = "10.0.${count.index + 3}.0/24"
  availability_zone = "ap-south-1"  # Change to your desired AZ
  vpc_id = aws_vpc.my_vpc.id   
}

resource "aws_security_group" "web_sg" {
  name_prefix = "web_sg"
  vpc_id = aws_vpc.my_vpc.id   # Associate the security group with the VPC
}

resource "aws_security_group" "app_sg" {
  name_prefix = "app_sg"
  vpc_id = aws_vpc.my_vpc.id   # Associate the security group with the VPC
}

resource "aws_security_group" "db_sg" {
  name_prefix = "db_sg"
  vpc_id = aws_vpc.my_vpc.id   # Associate the security group with the VPC
}

resource "aws_instance" "web_instances" {
  count = 2
  ami = "ami-0f5ee92e2d63afc18"  # Replace with your desired AMI ID
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public_subnet[count.index].id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "Web-Instance-${count.index + 1}"
  }
}

resource "aws_instance" "app_instances" {
  count = 2
  ami = "ami-0f5ee92e2d63afc18"  # Replace with your desired AMI ID
  instance_type = "t2.micro"
  subnet_id = aws_subnet.private_subnet[count.index].id
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  tags = {
    Name = "App-Instance-${count.index + 1}"
  }
}

resource "aws_instance" "db_instances" {
  count = 2
  ami = "ami-0f5ee92e2d63afc18"  # Replace with your desired AMI ID
  instance_type = "t2.micro"
  subnet_id = aws_subnet.private_subnet[count.index].id
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  tags = {
    Name = "DB-Instance-${count.index + 1}"
  }
}

