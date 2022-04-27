provider "aws" {
  region = "ap-northeast-2"
}

locals {
    user_data = <<EOF
    #!/bin/bash
    echo "Hello Terraform!"
    EOF 
}


resource "aws_instance" "server" {
    count                   = 1
    ami                     = "ami-0454bb2fefc7de534" // ubuntu_focal 20.04 x86
    instance_type           = "m5.large"
    key_name                = "gcar202101"
    vpc_security_group_ids  = ["sg-0327ff5d4f24283e9"]
    subnet_id               = "subnet-bc8c95f0"
    associate_public_ip_address = true
 
    credit_specification {
        cpu_credits = "unlimited"
    }

    tags = {
        Name = "dev-server"
        Terraform   = "true"
        Environment = "dev"
        Organization = "SoulJamWork"
        Group = "dev"
    }  

    provisioner "local-exec" {
        command = "echo dev ansible_host=${self.private_ip} ip=${self.public_ip} > inventory.txt"
    }

    connection {
        user = "ubuntu"
        host = self.public_ip
        private_key = file(pathexpand("~/.ssh/gcar202101.pem"))
        agent = "false"
        timeout = "5m"
    }
    
    provisioner "remote-exec" {
        inline = [
            "sudo apt -y update" 
        ]
    }
} 