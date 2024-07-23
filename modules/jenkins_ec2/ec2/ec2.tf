 resource "aws_instance" "my_ec2" {
  instance_type               = "t3.large"
  ami                         = "ami-0718fe4d8bab335d3" #CIS AMI ID in us-west-2 region
  subnet_id                   = var.private_subnet_id
  vpc_security_group_ids      = [aws_security_group.Spaces-Prod-jenkins-ec2_sg.id]
  key_name                    = aws_key_pair.jenkins_key_pair.key_name
  iam_instance_profile        = aws_iam_instance_profile.EC2_Jenkins.name
  monitoring                  = true
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = tls_private_key.keypair.private_key_pem
    host        = aws_instance.my_ec2.public_ip
  }

#   provisioner "remote-exec" {
#     inline = [
#       "sudo yum update -y",
#       "sudo yum install -y yum-utils",
#       "sudo yum install -y git",
#       "sudo yum install -y unzip",
#       # Install Terraform
#       "sudo wget https://releases.hashicorp.com/terraform/1.4.6/terraform_1.4.6_linux_amd64.zip",
#       "sudo unzip terraform_1.4.6_linux_amd64.zip",
#       "sudo mv terraform /usr/local/bin/",
#       # Install Terragrunt
#       "sudo wget https://github.com/gruntwork-io/terragrunt/releases/download/v0.49.0/terragrunt_linux_amd64",
#       "sudo mv terragrunt_linux_amd64 /usr/local/bin/terragrunt",
#       "sudo chmod +x /usr/local/bin/terragrunt"
#     ]

#  connection {
#     type        = "ssh"
#     user        = "ec2-user"
#     private_key = "${path.module}/spaces-prod-developer-admin-key.pem"
#     host        = aws_instance.my_ec2.private_ip
#   }
# }
  

root_block_device {
    volume_type           = "gp2"
    volume_size           = 500
    encrypted             = true
    kms_key_id            = data.aws_kms_key.my_key.arn  # Specify your KMS key ID
    delete_on_termination = true
  }

  # Additional EBS volume
  ebs_block_device {
    device_name           = "/dev/sdf"
    volume_type           = "gp2"
    volume_size           = 1000
    encrypted             = true
    kms_key_id            = data.aws_kms_key.my_key.arn  # Specify your KMS key ID
    delete_on_termination = true
  }

  user_data = <<EOF
#!/bin/bash
set -xe
sudo mkfs -t ext4 /dev/nvme1n1
sudo mkdir /apps
sudo mount /dev/nvme1n1 /apps

UUID=$(sudo blkid -s UUID -o value /dev/nvme1n1)
sudo sh -c "echo 'UUID=$UUID /apps ext4 defaults,nofail 0 2' >> /etc/fstab"
sudo yum install wget

sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum upgrade -y
sudo yum install git
sudo yum install telnet
sudo yum install -y java-17-amazon-corretto-devel -y
sudo yum install jenkins -y
sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo chmod 777 -R /apps/
sudo systemctl stop jenkins
sudo sed -i 's|/var/lib/jenkins|/apps|g' /lib/systemd/system/jenkins.service
sudo systemctl daemon-reload
sudo systemctl restart jenkins
sudo systemctl enable jenkins
sleep 20
sudo yum install firewalld -y
sleep 20
sudo systemctl start firewalld
sleep 40
sudo systemctl enable firewalld
sleep 10
sudo firewall-cmd --zone=public --add-port=8080/tcp --permanent
sleep 10
sudo systemctl restart firewalld
sudo hostnamectl set-hostname Jenkins-prodgov-jen-001
password=$(sudo cat /apps/secrets/initialAdminPassword)
echo "$password"

EOF
  tags = ({Name = var.instance_name, Project_Name = "Cisco-FedRAMP_Infrastructure", Date = local.current_date, "cdo-gov:CiscoMailAlias" = "gcc-fedramp-opstack@cisco.com", "cdo-gov:opstack:ApplicationName" = "Spaces", "cdo-gov:opstack:Environment" = "Prod", "cdo-gov:opstack:ResourceOwner" = "jagashet", deployed_fromdir = "bu-interlock-1/day-0", "cdo-gov:Opstack:DataClassificationFed" = "Direct Impact"})
depends_on = [aws_security_group.Spaces-Prod-jenkins-ec2_sg,aws_iam_role.Amazon_EC2_Jenkins]
}
