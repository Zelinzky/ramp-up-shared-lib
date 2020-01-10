provider "aws" {
  region = "us-east-2"
}

variable "server_port" {
  description = "The port the service will use"
  type = number
  default = 8080
}

resource "aws_security_group" "exampleEC2" {
  name = "terraform-example-instance"
  ingress {
    from_port = var.server_port
    protocol = "tcp"
    to_port = var.server_port
    cidr_blocks = [
      "0.0.0.0/0"]
  }
}

resource "aws_instance" "exampleEC2" {
  ami = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.exampleEC2.id]

  user_data_base64 = <<-EOF
                     #!/bin/bash
                     echo "Hello, World" > index.html
                     nohup busybox httpd -f -p ${var.server_port} &
                     EOF

  tags {
    Name = "terraform-example"
  }
}

output "publicIP" {
  value = aws_instance.exampleEC2.public_ip
  description = "The public ip of the created instance"
}



