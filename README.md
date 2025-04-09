# Terraform EC2 Instance Setup

This repository contains the Terraform configuration to deploy an EC2 instance on AWS. The instance will have Apache HTTP Server installed and will display a "Welcome to my Terraform-deployed server!" message. The EC2 instance is configured to allow SSH access on port 22 and HTTP access on port 80.

## Table of Contents
- [Terraform EC2 Instance Setup](#terraform-ec2-instance-setup)
  - [Table of Contents](#table-of-contents)
  - [Project Overview](#project-overview)
  - [Requirements](#requirements)
  - [Setup Instructions](#setup-instructions)
    - [Task 1: Terraform Configuration for EC2 Instance](#task-1-terraform-configuration-for-ec2-instance)
    - [Task 2: User Data Script Execution](#task-2-user-data-script-execution)
    - [Task 3: Accessing the Web Server](#task-3-accessing-the-web-server)
  - [Terraform Configuration Breakdown](#terraform-configuration-breakdown)
  - [EC2 Instance and Key Pair](#ec2-instance-and-key-pair)
  - [SSH Key Pair](#ssh-key-pair)
  - [Outputs](#outputs)
- [Security Considerations i could implement](#security-considerations-i-could-implement)

## Project Overview
This project automates the creation of an EC2 instance using Terraform. The EC2 instance will:
- Be a `t2.micro` instance.
- Have Apache HTTP Server installed and running.
- Display a "Welcome to my Terraform-deployed server!" HTML message on its web server.
- Be secured with SSH access and a security group allowing inbound HTTP traffic.

## Requirements
- [Terraform](https://www.terraform.io/downloads.html) installed on your local machine.
- An AWS account with appropriate permissions to create EC2 instances, security groups, and key pairs.
- AWS credentials set up (either using `aws configure` or environment variables).

## Setup Instructions

### Task 1: Terraform Configuration for EC2 Instance
1. Clone this repository and navigate to the project directory:
   ```bash
   git clone <repository-url>
   cd terraform-ec2-keypair


2. Initialize the Terraform project:

```bash

terraform init
Apply the Terraform configuration to create the EC2 instance:
```

```bash
terraform apply
```

### Task 2: User Data Script Execution
1. Extend the Terraform configuration to include the execution of a user data script. The script installs and configures the Apache HTTP server and creates a simple HTML page that displays the message "Welcome to my Terraform-deployed server!".

2. Re-apply the Terraform configuration:

```bash
terraform apply
```
 This will launch the EC2 instance with the updated user data script.

### Task 3: Accessing the Web Server
1. After the EC2 instance is created and running, use the public IP address of the instance to access the Apache web server:

```bash
http://3.148.222.235
```

2. Verify that the web server displays the following message:

```bash
Welcome to my Terraform-deployed server!
```


## Terraform Configuration Breakdown
Security Group
```bash
resource "aws_security_group" "terraform_sg" {
  name        = "terraform_sg"
  description = "Security group for Terraform EC2 instance"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH from any IP
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP from any IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # All protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

## EC2 Instance and Key Pair

```bash
resource "aws_instance" "terraform_server" {
    ami = "ami-04f167a56786e4b09"
    instance_type = "t2.micro"
    key_name = aws_key_pair.terraform_keypair.key_name
    security_groups = [aws_security_group.terraform_sg.name]

    user_data = <<-EOF
      #!/bin/bash
      sudo apt update -y
      sudo apt install -y apache2
      sudo systemctl start apache2
      sudo systemctl enable apache2
      echo "<html><body><h1>Welcome to my Terraform-deployed server!</h1></body></html>" > /var/www/html/index.html
      sudo chmod 644 /var/www/html/index.html
      sudo chown www-data:www-data /var/www/html/index.html
      sudo systemctl status apache2
    EOF

    tags = {
        Name = "MyTerraformInstance"
    }
}

```
## SSH Key Pair 

```bash 
  resource "aws_key_pair" "terraform_keypair" {
  key_name   = "terraform-keypair"
  public_key = tls_private_key.terraform_key.public_key_openssh
}
```
## Outputs
 * Private Key: The private key used to SSH into the EC2 instance is generated and saved locally.

 * Public IP: The public IP of the EC2 instance is outputted to access the web server.

```bash
  output "private_key" {
  value     = tls_private_key.terraform_key.private_key_pem
  sensitive = true
}

output "public_ip" {
  value = aws_instance.terraform_server[0].public_ip
}
```
**web server displays the data script**
 - web server displays the data script
 ![web server displays the data script](./Screenshot%202025-04-09%20155006.png)
 
 ---
# Security Considerations i could implement
- Ensure the private key file (terraform-keypair.pem) is stored securely, and access is restricted with appropriate permissions (e.g., chmod 0400 terraform-keypair.pem).


- Modify the security group ingress rules to limit access based on trusted IP addresses instead of 0.0.0.0/0 for better security.

