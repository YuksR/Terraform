# create VPC

resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Terraform-VPC"
  }
}

# Creating Three Public Subnets

resource "aws_subnet" "pubsn1" {
  vpc_id = aws_vpc.myvpc.id
  availability_zone = "us-east-1a"
  cidr_block = "10.0.0.0/24"
}

resource "aws_subnet" "pubsn2" {
  vpc_id = aws_vpc.myvpc.id
  availability_zone = "us-east-1b"
  cidr_block = "10.0.1.0/24"
}

resource "aws_subnet" "pubsn3" {
   vpc_id = aws_vpc.myvpc.id
   availability_zone = "us-east-1c"
   cidr_block = "10.0.2.0/24"
}

# Creating two Private Subnets

resource "aws_subnet" "pvtsn1" {
  vpc_id = aws_vpc.myvpc.id
  availability_zone = "us-east-1a"
  cidr_block = "10.0.3.0/24"
}


resource "aws_subnet" "pvtsn2" {
  vpc_id = aws_vpc.myvpc.id
  availability_zone = "us-east-1b"
  cidr_block = "10.0.4.0/24"
}

# Create Internet Gateway

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
}

# Create Elastic ip 

resource "aws_eip" "eip" {
    depends_on = [ aws_internet_gateway.igw ] 
}

# Create Nat Gateway

resource "aws_nat_gateway" "ngw" {
    allocation_id = aws_eip.eip.id
    subnet_id = aws_subnet.pubsn1.id
    depends_on = [ aws_eip.eip ]
}

# Create Route Table for Public Subnet

resource "aws_route_table" "pubrt" {
    vpc_id = aws_vpc.myvpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }

    tags = {
       Name = "PUB-RT"
  }
  
}

# Route Table Association for Three Public Subnets

resource "aws_route_table_association" "rtapub1" {
    route_table_id = aws_route_table.pubrt.id
    subnet_id = aws_subnet.pubsn1.id 
}

resource "aws_route_table_association" "rtapub2" {
  route_table_id = aws_route_table.pubrt.id
  subnet_id = aws_subnet.pubsn2.id
}

resource "aws_route_table_association" "rtapub3" {
  route_table_id = aws_route_table.pubrt.id
  subnet_id = aws_subnet.pubsn3.id
}

# Route Table for Private Subnets

resource "aws_route_table" "rtpvt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }

  tags = {
    Name = "PVT-Rt"
  }
}

# Route Table Association for 2 Private Subnets

resource "aws_route_table_association" "rtapvt1" {
    route_table_id = aws_route_table.rtpvt.id
    subnet_id = aws_subnet.pvtsn1.id
}

resource "aws_route_table_association" "rtapvt2" {
    route_table_id = aws_route_table.rtpvt.id
    subnet_id = aws_subnet.pvtsn2.id
}
