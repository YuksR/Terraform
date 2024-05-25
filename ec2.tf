
# Security Group for Jump Server
resource "aws_security_group" "jumpsg" {
  name        = "Jump-SG"
  description = "Security Group for Jump Server"
  vpc_id      = "vpc-0082876695bb9b326" # Change VPC id
  tags = {
    Name = "Jump-Sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_22_ipv4" {
  security_group_id = aws_security_group.jumpsg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.jumpsg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" 
}

# Security Group for Private Instance

resource "aws_security_group" "pvtsg" {
  name        = "PVT_SG"
  description = "Allow SSH inbound traffic from Jump Server SG"
  vpc_id      = "vpc-0082876695bb9b326" # Change VPC id

  tags = {
    Name = "Pvt-sg"
  }

    ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [ aws_security_group.jumpsg.id ]
  }

    egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}

# Local key Stored in Instance
resource "aws_key_pair" "pubkey" {
  key_name   = "tfkey"
  public_key = tls_private_key.key.public_key_openssh
}

# RSA key of size 4096 bits
resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Generate Private Key in Local 
resource "local_file" "pvtkey" {
  content  =  tls_private_key.key.private_key_pem
  filename = "tfkey.pem"
}

resource "aws_instance" "jumpserv" {
  ami = "ami-0bb84b8ffd87024d8"
  instance_type = "t2.micro"
  key_name = "tfkey"
  subnet_id = "subnet-097be78eb7e1415e6" # Change Subnet id
  associate_public_ip_address = true
  vpc_security_group_ids = [ aws_security_group.jumpsg.id ]

  tags = {
    Name = "Jump-Server"
  }
}

resource "aws_instance" "Pvtserv" {
  ami = "ami-0bb84b8ffd87024d8"
  instance_type = "t2.micro"
  key_name = "tfkey"
  subnet_id = "subnet-0f298127c9a57cc2c" # Change Subnet id
  vpc_security_group_ids = [ aws_security_group.pvtsg.id ]

  tags = {
    Name = "PVt-Instance"
  }
}

output "JUMP_Server_IP" {
  value = aws_instance.jumpserv.public_ip
}