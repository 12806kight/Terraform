resource "aws_vpc" "mtc_vpc" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "dev"
  }
}

resource "aws_subnet" "mtc_public_subnet" {
  vpc_id                  = aws_vpc.mtc_vpc.id
  cidr_block              = "10.123.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"

  tags = {
    Name = "dev-public"
  }
}

resource "aws_internet_gateway" "mtc_internet_gateway" {
  vpc_id = aws_vpc.mtc_vpc.id

  tags = {
    Name = "dev-igw"
  }
}

resource "aws_route_table" "mtc_public_route" {
  vpc_id = aws_vpc.mtc_vpc.id

  tags = {
    Name = "dev_public_route"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.mtc_public_route.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.mtc_internet_gateway.id
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.mtc_public_subnet.id
  route_table_id = aws_route_table.mtc_public_route.id
}

resource "aws_security_group" "mtg_sg" {
  name        = "sg"
  description = "dev security group"
  vpc_id      = aws_vpc.mtc_vpc.id
  ingress  {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "mtc_auth"{
    key_name = "mtckey"
    public_key = file("~/.ssh/mtckey.pub")
}

resource "aws_instance" "dev_node"{
    instance_type = "t2.micro"
    ami = data.aws_ami.server_ami.id

    tags = {
        Name = "dev-node"
    }

    key_name = aws_key_pair.mtc_auth.id
    vpc_security_group_ids = [aws_security_group.mtg_sg.id]
    subnet_id = aws_subnet.mtc_public_subnet.id
}