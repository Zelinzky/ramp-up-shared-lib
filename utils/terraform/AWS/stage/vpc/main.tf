terraform {
  backend "s3" {
    bucket = "devops-rampup-rlargot-tfstate"
    key = "stage/vpc/terraform.tfstate"
    region = "us-east-1"

    dynamodb_table = "devops-rampup-rlargot-tflocks"
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "movie_main_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "${var.project_name}-${var.environment_name}-vpc"
    User = var.user_tag
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.movie_main_vpc.id
  tags = {
    Name = "${var.project_name}-${var.environment_name}-gw"
    User = var.user_tag
  }
}

resource "aws_subnet" "movie_public_sub_a" {
  cidr_block = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  vpc_id = aws_vpc.movie_main_vpc.id
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_name}-${var.environment_name}-public-subnet-a"
    User = var.user_tag
  }
}
resource "aws_subnet" "movie_public_sub_b" {
  cidr_block = "10.0.4.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
  vpc_id = aws_vpc.movie_main_vpc.id
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_name}-${var.environment_name}-public-subnet-b"
    User = var.user_tag
  }
}

resource "aws_route_table" "movie_public_sub" {
  vpc_id = aws_vpc.movie_main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "${var.project_name}-${var.environment_name}-public-subnet-route-table"
    User = var.user_tag
  }
}

resource "aws_route_table_association" "movie_public_sub_a" {
  route_table_id = aws_route_table.movie_public_sub.id
  subnet_id = aws_subnet.movie_public_sub_a.id
}
resource "aws_route_table_association" "movie_public_sub_b" {
  route_table_id = aws_route_table.movie_public_sub.id
  subnet_id = aws_subnet.movie_public_sub_b.id
}

resource "aws_subnet" "movie_private_sub" {
  cidr_block = "10.0.2.0/24"
  vpc_id = aws_vpc.movie_main_vpc.id
  tags = {
    Name = "${var.project_name}-${var.environment_name}-private-subnet"
    User = var.user_tag
  }
}

resource "aws_subnet" "movie_db_sub" {
  cidr_block = "10.0.3.0/24"
  vpc_id = aws_vpc.movie_main_vpc.id
  tags = {
    Name = "${var.project_name}-${var.environment_name}-db-subnet"
    User = var.user_tag
  }
}

