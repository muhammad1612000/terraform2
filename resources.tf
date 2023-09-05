resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow http inbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description      = "allow_http"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [var.everywhere]
    
  }

ingress {
    description      = "allow_ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.everywhere]
    
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.everywhere]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_http"
  }
}
resource "aws_vpc" "myvpc" {
  cidr_block       =  var.vpc_cidr
 

  tags = {
    Name = "lab2"
  }
}

resource "aws_subnet" "mysubnet" {
  for_each = var.CIDRS
  vpc_id = aws_vpc.myvpc.id
  cidr_block = each.value

  tags = {
    Name = each.key
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "lab2-igw"
  }
}

resource "aws_route_table" "rt1" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = var.everywhere
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "igw-rt"
  }
}
resource "aws_route_table" "rt2" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = var.everywhere
    nat_gateway_id= aws_nat_gateway.mynat.id
  }
  tags = {
    Name = "natgw-rt"
  }
}

resource "aws_eip" "lb" {
  domain   = "vpc"
}

resource "aws_nat_gateway" "mynat" {
  allocation_id = aws_eip.lb.id
  subnet_id     = aws_subnet.mysubnet["public_subnet"].id

  tags = {
    Name = "gw NAT"
  }

}
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.mysubnet["public_subnet"].id
  route_table_id = aws_route_table.rt1.id
}

resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.mysubnet["private_subnet"].id
  route_table_id = aws_route_table.rt2.id
}


resource "aws_instance" "apache" {
  for_each = var.CIDRS
  ami           = var.ami
  instance_type = var.instance_type                                

  vpc_security_group_ids = [aws_security_group.allow_http.id]
  subnet_id     = aws_subnet.mysubnet[each.key].id 
  associate_public_ip_address = var.associate_public_ip_address[each.key]
  key_name = var.key_name
  user_data = var.user_data
  tags = {
    Name = "${each.key}_instance "
  }
}

