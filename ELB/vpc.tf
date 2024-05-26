resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "TERRAFORM-VPC"
  }
}

resource "aws_subnet" "sn1" {
  vpc_id = aws_vpc.myvpc.id
  availability_zone = "us-east-1a"
  cidr_block = "10.0.0.0/24"
}

resource "aws_subnet" "sn2" {
  vpc_id = aws_vpc.myvpc.id
  availability_zone = "us-east-1b"
  cidr_block = "10.0.1.0/24"
}

resource "aws_subnet" "sn3" {
  vpc_id = aws_vpc.myvpc.id
  availability_zone = "us-east-1c"
  cidr_block = "10.0.2.0/24"
}

resource "aws_subnet" "sn4" {
  vpc_id = aws_vpc.myvpc.id
  availability_zone = "us-east-1b"
  cidr_block = "10.0.3.0/24"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
}

resource "aws_eip" "eip" {
  depends_on = [ aws_internet_gateway.igw ]
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id = aws_subnet.sn1.id
  depends_on = [ aws_eip.eip ]
}
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table" "pvtrt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }
}

resource "aws_route_table_association" "rta" {
  route_table_id = aws_route_table.rt.id
  subnet_id = aws_subnet.sn1.id
}

resource "aws_route_table_association" "rta1" {
  route_table_id = aws_route_table.pvtrt.id
  subnet_id = aws_subnet.sn2.id
}

resource "aws_route_table_association" "rta2" {
  route_table_id = aws_route_table.pvtrt.id
  subnet_id = aws_subnet.sn3.id
}

resource "aws_route_table_association" "rta3" {
  route_table_id = aws_route_table.rt.id
  subnet_id = aws_subnet.sn4.id
}
