#resource block
# Define the Security Group
resource "aws_security_group" "terraform_sg" {
  name        = "terraform_sg"
  description = "Security group for Terraform EC2 instance"
  
  # Allow SSH inbound access on port 22
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH from any IP (change for more security)
  }

  # Allow HTTP inbound access on port 80 (optional, if you're installing Apache)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP from any IP (change for more security)
  }

  # Allow all outbound traffic (default)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # All protocols
    cidr_blocks = ["0.0.0.0/0"]  # Allow outbound to any IP
  }
}


# Generate a new SSH key pair
resource "tls_private_key" "terraform_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Store the private key locally
resource "local_file" "private_key" {
  content         = tls_private_key.terraform_key.private_key_pem
  filename        = "${path.module}/terraform-keypair.pem"
  file_permission = "0400" # Set appropriate permissions for SSH key
}


resource "aws_key_pair" "terraform_keypair"{
  key_name = "terraform-keypair"
  public_key = tls_private_key.terraform_key.public_key_openssh
}


resource "aws_instance" "terraform_server"{
    ami = "ami-04f167a56786e4b09"
    instance_type = "t2.micro"
    count = 1
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

    provisioner "remote-exec"{
        inline = [
            "sudo apt update -y",
            "sudo apt install -y apache2",
            "echo '<html><body><h1>Welcome to my Terraform-deployed server!</h1></body></html>' | sudo tee /var/www/html/index.html",
            "sudo chmod 644 /var/www/html/index.html",
            "sudo chown www-data:www-data /var/www/html/index.html"
        ]
        connection {
          type = "ssh"
          user = "ubuntu"
          private_key = tls_private_key.terraform_key.private_key_pem
          host = self.public_ip
        }
      
    }


    tags = {
        Name = "MyTerraformInstance"
    }
}

resource "aws_ami_from_instance" "example_ami"  {
    name = "example_ami"
  
    source_instance_id = aws_instance.terraform_server[0].id
     
    description = "AMI created for my Terraform instance"
 
}

# Create a downloadable output for the private key
output "private_key" {
  value     = tls_private_key.terraform_key.private_key_pem
  sensitive = true
}

output "public_ip" {
  value = aws_instance.terraform_server[0].public_ip
}