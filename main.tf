terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-west-2"
}

data "aws_ami" "ubuntu_latest" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "mail_server_sg" {

  name = "mail server rules"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_instance" "mail_server" {
  ami                         = "${data.aws_ami.ubuntu_latest.id}"
  instance_type               = "t2.micro"
  key_name                    = "us-west-2-mail"
  vpc_security_group_ids      = ["${aws_security_group.mail_server_sg.id}"]
  user_data                   = "${file("install_server.sh")}"
  user_data_replace_on_change = true

  tags = {
    Name = "mail server"
  }
}
