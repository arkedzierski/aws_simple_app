##################################################################################
# EC2
##################################################################################

# EC2 bastion
resource "aws_instance" "ec2" {
  ami                         = var.image_id
  instance_type               = var.instance_type
  associate_public_ip_address = var.enable_public_ip
  key_name                    = var.key_name
  vpc_security_group_ids      = var.security_group_ids
  subnet_id                   = var.subnet_id
  user_data                   = <<-EOL
#!/bin/bash

sudo apt-get update
sudo apt-get install postgresql-client -y
EOL
  tags                        = { Name = "${var.owner}-ec2${var.name}" }
}
