# security Group for Bastion Host

resource "aws_security_group" "bsg" {
  name        = "Bastion-SG"
  description = "Security Group for Bastion Host"
  vpc_id      =  aws_vpc.myvpc.id

  tags = {
    Name = "Bastion-SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.bsg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}


resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.bsg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# Security Group for Load Balancer
resource "aws_security_group" "alb" {
  name        = "ALB-SG"
  description = "Security Group for Load Balancer"
  vpc_id      =  aws_vpc.myvpc.id

  tags = {
    Name = "ALB-SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}


resource "aws_vpc_security_group_egress_rule" "allow_all_ipv4" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# Security Group for Web Server
resource "aws_security_group" "ws" {
  name        = "WEB-SG"
  description = "Security Group for WEB SERVER"
  vpc_id      =  aws_vpc.myvpc.id

  tags = {
    Name = "WEB-SG"
  }

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups = [ aws_security_group.bsg.id ]
  }

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups = [ aws_security_group.alb.id ]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

# Bastion Host
resource "aws_instance" "bas" {
  ami = "ami-0bb84b8ffd87024d8"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.sn1.id
  associate_public_ip_address = false
  security_groups = [ aws_security_group.bsg.id ]
}

# Web Server 1
resource "aws_instance" "webs1" {
    ami = "ami-0bb84b8ffd87024d8"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.sn2.id
    associate_public_ip_address = false
    security_groups = [ aws_security_group.ws.id ]
    user_data = file("userdata1.sh")
}

# Web Server 2
resource "aws_instance" "web2" {
    ami = "ami-0bb84b8ffd87024d8"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.sn3.id
    associate_public_ip_address = false
    security_groups = [ aws_security_group.ws.id ]
    user_data = file("userdata2.sh")
}

