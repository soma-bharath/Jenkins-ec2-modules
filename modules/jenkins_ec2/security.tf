resource "aws_security_group" "Spaces-prod-jenkins-alb-sg" {
  name        = "Spaces-prod-jenkins-alb-sg"
  description = "Security group for the ALB"
  vpc_id      = data.aws_vpc.spaces-prod-app-1.id

    tags = ({Name = "Spaces-Prod-jenkins-alb-sg", Project_Name = "Cisco-FedRAMP_Infrastructure", Date = local.current_date, "cdo-gov:CiscoMailAlias" = "gcc-fedramp-opstack@cisco.com", "cdo-gov:opstack:ApplicationName" = "Spaces", "cdo-gov:opstack:Environment" = "Prod", "cdo-gov:opstack:ResourceOwner" = "jagashet", deployed_fromdir = "bu-interlock-1/day-0", "cdo-gov:Opstack:DataClassificationFed" = "Direct Impact"})


  

  // Define ingress rules if needed
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"] // Allow traffic from anywhere
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"] // Allow traffic from anywhere
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"] // Allow traffic from anywhere
  }

  // Define egress rules if needed
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] // Allow traffic to anywhere
  }
}


resource "aws_security_group" "Spaces-Prod-jenkins-ec2_sg" {
  name        = var.security_group_name_ec2
  description = "Security group for the ec2"
  vpc_id      = data.aws_vpc.spaces-prod-app-1.id

 tags = ({Name = "Spaces-Prod-jenkins-ec2_sg", Project_Name = "Cisco-FedRAMP_Infrastructure", Date = local.current_date, "cdo-gov:CiscoMailAlias" = "gcc-fedramp-opstack@cisco.com", "cdo-gov:opstack:ApplicationName" = "Spaces", "cdo-gov:opstack:Environment" = "Prod", "cdo-gov:opstack:ResourceOwner" = "jagashet", deployed_fromdir = "bu-interlock-1/day-0", "cdo-gov:Opstack:DataClassificationFed" = "Direct Impact"})


  // Define egress rules if needed
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] // Allow traffic to anywhere
  }
}

resource "aws_security_group_rule" "allow_443" {
  type   = "ingress"
  security_group_id = aws_security_group.Spaces-Prod-jenkins-ec2_sg.id  
  source_security_group_id = aws_security_group.Spaces-prod-jenkins-alb-sg.id
  from_port         = 443
  protocol       = "tcp"
  to_port           = 443
}
resource "aws_security_group_rule" "allow_80" {
  type   = "ingress"
  security_group_id = aws_security_group.Spaces-Prod-jenkins-ec2_sg.id
  source_security_group_id = aws_security_group.Spaces-prod-jenkins-alb-sg.id
  from_port         = 80
  protocol       = "tcp"
  to_port           = 80
}
resource "aws_security_group_rule" "allow_8080" {
  type   = "ingress"
  security_group_id = aws_security_group.Spaces-Prod-jenkins-ec2_sg.id
  source_security_group_id = aws_security_group.Spaces-prod-jenkins-alb-sg.id
  from_port         = 8080
  protocol       = "tcp"
  to_port           = 8080
}

resource "aws_security_group_rule" "allow_22" {
  type   = "ingress"
  security_group_id = aws_security_group.Spaces-Prod-jenkins-ec2_sg.id
  cidr_blocks = [var.my_machine_ip]
  from_port         = 22
  protocol       = "tcp"
  to_port           = 22
}