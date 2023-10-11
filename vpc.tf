resource "aws_vpc" "my_vpc" {
  cidr_block           = "172.30.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "172.30.10.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "172.30.20.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "172.30.100.0/24"
  availability_zone = "us-east-1a"
}


resource "aws_internet_gateway" "int_gat" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.int_gat.id
  }
}

resource "aws_route_table_association" "public_rta" {
  route_table_id = aws_route_table.public_route.id
  subnet_id      = aws_subnet.public_subnet.id
}

resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_route_table_association" "private_rta_a" {
  route_table_id = aws_route_table.private_route.id
  subnet_id      = aws_subnet.private_subnet_a.id
}

resource "aws_route_table_association" "private_rta_b" {
  route_table_id = aws_route_table.private_route.id
  subnet_id      = aws_subnet.private_subnet_b.id
}

resource "aws_security_group" "sg_padrao" {
  name   = "Security Group Monitoramento"
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    description = "allow_10050-zabbix"
    from_port   = 10050
    to_port     = 10050
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.my_vpc.cidr_block]
  }

  ingress {
    description = "allow_3000-grafana"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "allow_icmp"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [aws_vpc.my_vpc.cidr_block]
  }

  ingress {
    description = "allow_22"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "allow_http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name = "Security_Group_Padrao"
  }
}


resource "aws_security_group" "bd_sg" {
  name   = "Security Group DataBase"
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    description     = "allow_3306"
    from_port       = "3306"
    to_port         = "3306"
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_padrao.id]
  }
}

resource "aws_db_subnet_group" "subnet_db" {
  name = "subnet_group_database"
  subnet_ids = [
    aws_subnet.private_subnet_a.id,
    aws_subnet.private_subnet_b.id,
  ]
}
