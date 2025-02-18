terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = ">= 5.0.0, <6.0.0"
    }
    random = {
        source = "hashicorp/random"
        version = ">= 3.6.0"
    }
  }
}
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
        managed_by = "Terraform"
        project = "AD"
    }
  }
}

provider "random" {
  
}

resource "random_string" "suffix" {
    length = 4
    special = false
    upper = false
}

data "aws_availability_zones" "current" {
    state = "available"
}

module "vpc" {
  # checkov:skip=CKV_TF_1: ADD REASON
    source  = "terraform-aws-modules/vpc/aws"
    version = "5.19.0"

    create_vpc = true
    name = "department-${random_string.suffix.result}"
    cidr = "172.20.0.0/16"
    public_subnets = ["172.20.10.0/24"]

    create_igw = true
    enable_nat_gateway = false
    one_nat_gateway_per_az = false
    azs = [data.aws_availability_zones.current.names[0]]
} 

data "aws_ami" "windows-server-2022" {
    owners           = ["801119661308"]
    most_recent      = true
    filter {
        name   = "name"
        values = ["Windows_Server-2022-English-Full-Base-*"]
    }
}

resource "aws_security_group" "windows-server" {
    description = "A security groupt for Windows Server access"
    vpc_id = module.vpc.vpc_id

}

resource "aws_vpc_security_group_ingress_rule" "rdp" {
  # checkov:skip=CKV_AWS_25: ADD REASON
    description = "RDP from anywhere"
    security_group_id = aws_security_group.windows-server.id
    cidr_ipv4         = "0.0.0.0/0"
    from_port         = 3389
    ip_protocol       = "tcp"
    to_port           = 3389
}

resource "aws_vpc_security_group_egress_rule" "any" {
  # checkov:skip=CKV_AWS_23: ADD REASON
    security_group_id = aws_security_group.windows-server.id
    cidr_ipv4 = "0.0.0.0/0"
    from_port = 0
    to_port = 0
    ip_protocol = "tcp"
}

resource "aws_instance" "windows-server-2022" {
  # checkov:skip=CKV_AWS_88: ADD REASON
    tags = {
      name = "Windows Server 2022 - ${random_string.suffix.result}"
    }
    ami = data.aws_ami.windows-server-2022.image_id
    key_name = var.key_name
    availability_zone = data.aws_availability_zones.current.names[0]
    subnet_id = module.vpc.public_subnets[0]
    instance_type = var.instance_type
    associate_public_ip_address = true 
    vpc_security_group_ids = [aws_security_group.windows-server.id,]
    
    metadata_options {
        http_tokens = "required"
        http_endpoint = "enabled"
    }
    monitoring = true
    ebs_optimized = true
    root_block_device {
        encrypted = true
    }
    user_data = <<-EOF
                <powershell>
                Install-WindowsFeature -name AD-Domain-Services -IncludeManagementTools
                Install-ADDSForest -DomainName "${var.dns_domain}" -ForestMode WinThreshold -DomainMode WinThreshold -DomainNetbiosName ${var.domain_netbios_name} -SafeModeAdministratorPassword (ConvertTo-SecureString -AsPlainText "${var.recovery_password}" -Force) -InstallDNS -Force
                </powershell>
                EOF
}

