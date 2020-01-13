variable "server_port_autoscale" {
  description = "The port the service will use"
  type = number
  default = 8080
}

data "aws_vpc" "defaultVPC" {
  default = true
}

data "aws_subnet_ids" "defaultVPCSubnets" {
  vpc_id = data.aws_vpc.defaultVPC.id
}

resource "aws_security_group" "exampleEC2AS" {
  name = "autoscale-example"
  ingress {
    from_port = var.server_port_autoscale
    protocol = "tcp"
    to_port = var.server_port_autoscale
    cidr_blocks = [
      "0.0.0.0/0"]
  }
}

resource "aws_launch_configuration" "exampleEC2AS" {
  image_id = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  security_groups = [
    aws_security_group.exampleEC2AS.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p ${var.server_port_autoscale} &
              EOF
  # Required to use launch config with ASG
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "exampleEC2AS" {
  launch_configuration = aws_launch_configuration.exampleEC2AS.name
  vpc_zone_identifier = data.aws_subnet_ids.defaultVPCSubnets.ids

  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  max_size = 5
  min_size = 0

  tag {
    key = "Name"
    propagate_at_launch = true
    value = "Terrafomr-asg-example"
  }
}

resource "aws_lb" "exampleEC2AS" {
  name = "terraform-asg-example"
  #other options: network or classic
  load_balancer_type = "application"
  subnets = data.aws_subnet_ids.defaultVPCSubnets.ids
  security_groups = [aws_security_group.alb-exmample.id]
}

resource "aws_security_group" "alb-exmample" {
  name = "terraform-example-alb"

  # Allow inbound http
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  # Allow all egress
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = [
      "0.0.0.0/0"]
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.exampleEC2AS.arn
  port = 80
  protocol = "HTTP"

  # Return a simple 404 by default
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code = 404
    }
  }
}

resource "aws_lb_target_group" "asg" {
  name = "asg-example"
  port = var.server_port_autoscale
  protocol = "HTTP"
  vpc_id = data.aws_vpc.defaultVPC.id

  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
    interval = 15
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}

resource "aws_alb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
  condition {
    field = "path-pattern"
    values = ["*"]
  }
}

output "alb_dns_name" {
  value = aws_lb.exampleEC2AS.dns_name
  description = "The dns of the load balancer"
}