resource "aws_vpc" "sample" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "${var.aws_prefix}-sample-vpc"
  }
}

resource "aws_internet_gateway" "sample" {
  vpc_id = aws_vpc.sample.id

  tags = {
    Name = "${var.aws_prefix}-sample-gateway"
  }

  depends_on = [
    aws_subnet.sample
  ]
}

resource "aws_subnet" "sample" {
  vpc_id = aws_vpc.sample.id

  cidr_block              = "10.1.0.0/24"
  availability_zone       = local.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.aws_prefix}-sample-subnet"
  }
}

resource "aws_route_table" "sample_route_table" {
  vpc_id = aws_vpc.sample.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sample.id
  }

  tags = {
    Name = "${var.aws_prefix}-sample-route-table"
  }
}

resource "aws_route_table_association" "sample_route_table_association" {
  subnet_id      = aws_subnet.sample.id
  route_table_id = aws_route_table.sample_route_table.id
}

resource "aws_security_group" "allow_all_https" {
  name        = "${var.aws_prefix}-allow-all-https-sg"
  description = "Allow HTTPS inbound traffic"
  vpc_id      = aws_vpc.sample.id

  ingress {
    description = "TLS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TLS"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${local.deployer_ip}/32"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
