output "win-server-public-ip" {
  value = aws_instance.windows-server-2022.public_ip
}

output "vpc-name" {
  value = module.vpc.name
}
