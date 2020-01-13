terraform {
  backend "s3" {
    bucket = "devops-rampup-rlargot-tfstate"
    key = "stage/services/movie-api/terraform.tfstate"
    region = "us-east-1"

    dynamodb_table = "devops-rampup-rlargot-tflocks"
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "movies_vpc" {
  filter {
    name = "tag:Name"
    values = ["${var.project_name}-${var.environment_name}-vpc"]
  }
}

data "aws_subnet_ids" "public_subnets" {
  vpc_id = data.aws_vpc.movies_vpc.id
  filter {
    name = "tag:Name"
    values = ["*public-subnet*"]
  }
}

resource "aws_launch_configuration" "movie_api_instance" {
  name_prefix = "movie-api-lc-"
  image_id = "ami-062f7200baf2fa504"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.movie_api_instance.id]
  user_data = file("install.sh")
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "movie_api_instance" {
  name = "movie-api-instance"
  vpc_id = data.aws_vpc.movies_vpc.id
  ingress {
    from_port = var.custom_server_port
    protocol = "tcp"
    to_port = var.custom_server_port
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_autoscaling_group" "movie_api" {
  launch_configuration = aws_launch_configuration.movie_api_instance.name
  vpc_zone_identifier = data.aws_subnet_ids.public_subnets.ids

  target_group_arns = [aws_lb_target_group.movie_api.arn]
  health_check_type = "ELB"

  max_size = 5
  min_size = 1
  tag {
    key = "Name"
    propagate_at_launch = true
    value = "movie-api-asg"
  }
  tag {
    key = "User"
    propagate_at_launch = true
    value = var.user_tag
  }
}

resource "aws_security_group" "movie_api_elb" {
  name = "movie-api-elb"
  vpc_id = data.aws_vpc.movies_vpc.id
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "movie_api_elb" {
  name = "movie-api-elb"
  load_balancer_type = "application"
  subnets = data.aws_subnet_ids.public_subnets.ids
  security_groups = [aws_security_group.movie_api_elb.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.movie_api_elb.arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code = "404"
    }
  }
}

resource "aws_lb_target_group" "movie_api" {
  name = "movie-api"
  port = var.custom_server_port
  protocol = "HTTP"
  vpc_id = data.aws_vpc.movies_vpc.id

  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
    interval = 300
    timeout = 60
    healthy_threshold = 3
    unhealthy_threshold = 10
  }
}

resource "aws_lb_listener_rule" "movie_api" {
  listener_arn = aws_lb_listener.http.arn
  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.movie_api.arn
  }

  condition {
    path_pattern {
      values = ["*"]
    }
  }
}
