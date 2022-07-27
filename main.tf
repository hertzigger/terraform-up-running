provider "aws" {
  region = "us-east-2"
}

variable "http_port" {
  description = "The port the server will use for HTTP service"
  type = number
  default = 8080
}

variable "ssh_port" {
  description = "The port the server will use for SSH service"
  type = number
  default = 22
}

resource "aws_security_group" "instance" {
  name = "terraform-example"
  ingress {
    from_port = var.http_port
    to_port = var.http_port
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = var.ssh_port
    to_port = var.ssh_port
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "example" {
  ami = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instance.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p ${var.http_port} &
              EOF

  key_name = "main"

  tags = {
    Name = "terraform-example"
  }
}

output "public_ip" {
  value = aws_instance.example.public_ip
  description = "The public IP address of the web server"
}