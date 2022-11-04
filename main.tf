resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = {
    Name = "Devos-vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Devos-igw"
  }
}

resource "aws_subnet" "pub_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-3a"

  tags = {
    Name = "Devos_Web_subnet_a"
  }
}

resource "aws_subnet" "pub_c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-northeast-3c"

  tags = {
    Name = "Devos_Web_subnet_c"
  }
}

resource "aws_subnet" "pub1_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "ap-northeast-3a"

  tags = {
    Name = "Devos_Was_subnet_a"
  }
}

resource "aws_subnet" "pub1_c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = "ap-northeast-3c"

  tags = {
    Name = "Devos_Was_subnet_c"
  }
}

resource "aws_subnet" "pub2_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.211.0/24"
  availability_zone = "ap-northeast-3a"

  tags = {
    Name = "Devos_DB_subnet_a"
  }
}

resource "aws_subnet" "pub2_c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.212.0/24"
  availability_zone = "ap-northeast-3c"

  tags = {
    Name = "Devos_DB_subnet_c"
  }
}

resource "aws_route_table" "pub" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Devos-rtb-public"
  }
}

resource "aws_route_table_association" "pub_a" {
  subnet_id      = aws_subnet.pub_a.id
  route_table_id = aws_route_table.pub.id
}

resource "aws_route_table_association" "pub_c" {
  subnet_id      = aws_subnet.pub_c.id
  route_table_id = aws_route_table.pub.id
}

resource "aws_route_table_association" "pub1_a" {
  subnet_id      = aws_subnet.pub1_a.id
  route_table_id = aws_route_table.pub.id
}

resource "aws_route_table_association" "pub1_c" {
  subnet_id      = aws_subnet.pub1_c.id
  route_table_id = aws_route_table.pub.id
}



resource "aws_security_group" "web" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from VPC"
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
    Name = "allow_http"
  }
}

resource "aws_security_group" "was" {
  name        = "allow_was"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "WAS from VPC"
    from_port   = 8080
    to_port     = 8080
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
    Name = "allow_was"
  }
}

resource "aws_security_group" "ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_security_group" "db" {
 name = "allow_mysql"
 description = "Allow MYSQL inbound traffic"
 vpc_id = aws_vpc.main.id
 ingress {
 description = "MYSQL from WEB"
 from_port = 3306
 to_port = 3306
 protocol = "tcp"
 security_groups = [aws_security_group.web.id]
 }
 egress {
 from_port = 0
 to_port = 0
 protocol = "-1"
 cidr_blocks = ["0.0.0.0/0"]
 }
 tags = {
 Name = "allow_mysql"
 } 
}

resource "aws_db_subnet_group" "devos-db" {
 name = "devos-db subnet group"
 subnet_ids = [aws_subnet.pub2_a.id, aws_subnet.pub2_c.id]
 tags = {
 Name = "Devos DB subnet group"
 }
}

resource "aws_instance" "web" {
  ami                         = "ami-0708689cfc3edb71d" # Amazon Linux 2 (Seoul)
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.web.id, aws_security_group.ssh.id]
  availability_zone           = "ap-northeast-3a"
  subnet_id                   = aws_subnet.pub_a.id
  associate_public_ip_address = true
  key_name                    = "bsw-ap-northeast-3"
  tags = {
    Name = "Devos-web"
  }
}

resource "aws_instance" "was" {
  ami                         = "ami-0708689cfc3edb71d" # Amazon Linux 2 (Seoul)
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.was.id, aws_security_group.ssh.id]
  availability_zone           = "ap-northeast-3a"
  subnet_id                   = aws_subnet.pub1_a.id
  associate_public_ip_address = true
  key_name                    = "bsw-ap-northeast-3"
  user_data = <<-EOF
              #!/bin/bash
              sudo yum install java-1.8.0-openjdk -y
              EOF
  tags = {
    Name = "Devos-was"
  }
}


resource "aws_db_instance" "devos-db" {
 identifier = "devos-db" # identifier_prefix
 engine = "mysql"
 engine_version = "8.0" # "5.7"
 allocated_storage = 20
 instance_class = "db.t3.micro"
 parameter_group_name = "default.mysql8.0" # "default.mysql5.7"
 option_group_name = "default:mysql-8-0"

 db_name = "tf"
 username = "master"
 password = "tf-password"
 multi_az = false
 skip_final_snapshot = true
 copy_tags_to_snapshot = true
 auto_minor_version_upgrade = false
 
 db_subnet_group_name = aws_db_subnet_group.devos-db.name
 vpc_security_group_ids = [aws_security_group.db.id]
}
