provider "aws" {
  region = "us-west-2"
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
}

resource "aws_key_pair" "key_pair" {
  key_name   = "ansible-key"
  public_key = tls_private_key.key.public_key_openssh
}


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["learn-packer-linux-aws"]
  }
  owners = ["340574226563"] 
}

resource "aws_instance" "ansible_server" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow.id]
  key_name = aws_key_pair.key_pair.key_name
  tags = {
    "Name" = "Apache Server"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install -y apache2",
      "sudo systemctl enable apache2.service",
      "sudo systemctl start apache2.service"
    ]
  }
  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = tls_private_key.key.private_key_pem
    host = self.public_ip
  }
} 
  
