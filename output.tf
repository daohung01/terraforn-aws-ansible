output "vm" {
    value = aws_instance.ansible_server.public_ip
}