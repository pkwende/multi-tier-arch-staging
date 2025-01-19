/*resource "aws_vpc" "vpc1" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name        = "Terraform-vpc"
    Environment = "Dev"
    Creted      = "Terraform"
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc1.id
  tags = {
    Name        = "Terraform-IGW"
    Environment = "Dev"
  }
}
#Creating Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  vpc = true
}
#Creating NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet1.id
}
#Creating Public  Subnet1
resource "aws_subnet" "public_subnet1" {
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name        = "Terraform-public-subnet1"
    Environment = "Dev"
  }
}
#Creating Public  Subnet2
resource "aws_subnet" "public_subnet2" {
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name        = "Terraform-public-subnet2"
    Environment = "Dev"
  }
} #Creating Private Subnet1
resource "aws_subnet" "private_subnet1" {
  vpc_id            = aws_vpc.vpc1.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name        = "Terraform-private-subnet1"
    Environment = "Dev"
  }
}
#Creating Private Subnet2
resource "aws_subnet" "private_subnet2" {
  vpc_id            = aws_vpc.vpc1.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name        = "Terraform-private-subnet2"
    Environment = "Dev"
  }
}
#Creating Route Table for Public Subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc1.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}
#Creating Route Table for Private Subnets
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc1.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway.id
  }
}
#Associating Public Subnets to Public Route Table
resource "aws_route_table_association" "public_subnet1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet2" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.public_route_table.id
}
#Associating Private Subnets to Private Route Table
resource "aws_route_table_association" "private_subnet1" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.private_route_table.id
}
resource "aws_route_table_association" "private_subnet2" {
  subnet_id      = aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.private_route_table.id
}
# creating security group
resource "aws_security_group" "lb_sg" {
  name        = "Terraform-sg-lb"
  description = "Allow HTTP traffic"
  vpc_id      = aws_vpc.vpc1.id

  ingress {
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
}

resource "aws_security_group" "instance_sg" {
  name        = "Terraform-instance-sg"
  description = "Allow traffic from LB"
  vpc_id      = aws_vpc.vpc1.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# load balancer
resource "aws_lb" "application_lb" {
  name               = "application-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]
}

resource "aws_lb_target_group" "target_group" {
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc1.id
}

resource "aws_lb_target_group_attachment" "server1" {
  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = aws_instance.server1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "server2" {
  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = aws_instance.server2.id
  port             = 80
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.application_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

# Ec2 instances
resource "aws_instance" "server1" {
  ami                    = "ami-043a5a82b6cf98947"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private_subnet1.id
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  user_data              = file("code.sh")
}

resource "aws_instance" "server2" {
  ami                    = "ami-043a5a82b6cf98947"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private_subnet2.id
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  user_data              = file("code.sh")
}
#print the url of the load balalncer app
output "load_balancer_dns_name" {
  value = aws_lb.application_lb.dns_name
}
*/
