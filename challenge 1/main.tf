provider "aws" {
  region = "ap-south-1"  # Change to your desired AWS region
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public_subnet" {
  count = 1
  cidr_block = "10.0.${count.index + 1}.0/24"
  availability_zone = "ap-south-1a"  # Change to your desired AZ
  vpc_id = aws_vpc.my_vpc.id
}

#-------------------------------
# Create an IGW for your new VPC
#-------------------------------
resource "aws_internet_gateway" "my_vpc_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

#----------------------------------
# Create an RouteTable for your VPC
#----------------------------------
resource "aws_route_table" "my_vpc_public" {
    vpc_id = aws_vpc.my_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my_vpc_igw.id
    }
}

#--------------------------------------------------------------
# Associate the RouteTable to the Subnet created at ap-south-1a
#--------------------------------------------------------------
resource "aws_route_table_association" "my_vpc_ap_south_1a_public" {
    subnet_id = aws_subnet.public_subnet[0].id
    route_table_id = aws_route_table.my_vpc_public.id
}

resource "aws_eip" "my_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "my_nat_gateway" {
  allocation_id = aws_eip.my_eip.id  # Replace with your Elastic IP ID
  subnet_id     = aws_subnet.public_subnet[0].id  # Replace with the appropriate subnet ID
}



resource "aws_subnet" "private_subnet_app" {
  count = 2
  cidr_block = "10.0.${count.index + 3}.0/24"
  availability_zone = "ap-south-1b"  # Change to your desired AZ
  vpc_id = aws_vpc.my_vpc.id
}


#---------------------------------
# Create an RouteTable for your APP
#---------------------------------
resource "aws_route_table" "my_vpc_private" {
    vpc_id = aws_vpc.my_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.my_nat_gateway.id

    }
}

#----------------------------------------------------------------
# Associate the APP RouteTable to the Subnet created at ap-south-1b
#----------------------------------------------------------------
resource "aws_route_table_association" "my_vpc_ap_south_1b_private" {
    subnet_id      = aws_subnet.private_subnet_app[0].id  # Use the appropriate subnet index
    route_table_id = aws_route_table.my_vpc_private.id
}


resource "aws_subnet" "private_subnet_db" {
  count = 3
  cidr_block = "10.0.${count.index + 5}.0/24"
  availability_zone = "ap-south-1b"  # Change to your desired AZ
  vpc_id = aws_vpc.my_vpc.id
}


#---------------------------------
# Create an RouteTable for your DB
#---------------------------------
resource "aws_route_table" "my_vpc_private1" {
    vpc_id = aws_vpc.my_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.my_nat_gateway.id

    }
}

#----------------------------------------------------------------
# Associate the DB RouteTable to the Subnet created at ap-south-1b
#----------------------------------------------------------------
resource "aws_route_table_association" "my_vpc_ap_south_1c_private" {
    subnet_id      = aws_subnet.private_subnet_db[0].id  # Use the appropriate subnet index
    route_table_id = aws_route_table.my_vpc_private1.id
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
  count = 1
  ami = "ami-0f5ee92e2d63afc18"  # Replace with your desired AMI ID
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public_subnet[count.index].id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "Web-Instance-${count.index + 1}"
  }
}

resource "aws_instance" "app_instances" {
  count = 1
  ami = "ami-0f5ee92e2d63afc18"  # Replace with your desired AMI ID
  instance_type = "t2.micro"
  subnet_id = aws_subnet.private_subnet_app[count.index].id
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  tags = {
    Name = "App-Instance-${count.index + 1}"
  }
}

resource "aws_instance" "db_instances" {
  count = 1
  ami = "ami-0f5ee92e2d63afc18"  # Replace with your desired AMI ID
  instance_type = "t2.micro"
  subnet_id = aws_subnet.private_subnet_db[count.index].id
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  tags = {
    Name = "DB-Instance-${count.index + 1}"
  }
}



