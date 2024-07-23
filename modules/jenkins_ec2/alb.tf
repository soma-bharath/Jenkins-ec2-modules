resource "aws_lb" "Jenkins_Alb" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  subnets            = [for j in data.aws_subnet.public_subnets : j.id]
  security_groups    = [aws_security_group.Spaces-prod-jenkins-alb-sg.id]

 tags = ({Name = var.alb_name, Project_Name = "Cisco-FedRAMP_Infrastructure", Date = local.current_date, "cdo-gov:CiscoMailAlias" = "gcc-fedramp-opstack@cisco.com", "cdo-gov:opstack:ApplicationName" = "Spaces", "cdo-gov:opstack:Environment" = "Prod", "cdo-gov:opstack:ResourceOwner" = "jagashet", deployed_fromdir = "bu-interlock-1/day-0", "cdo-gov:Opstack:DataClassificationFed" = "Direct Impact"})

depends_on = [aws_instance.my_ec2]
}

resource "aws_lb_target_group" "Jenkins_target_group" {
  name        = "Jenkins-target-group"
  port        = 8080
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      =  data.aws_vpc.spaces-prod-app-1.id
    tags = ({Name = "Jenkins-target-group", Project_Name = "Cisco-FedRAMP_Infrastructure", Date = local.current_date, "cdo-gov:CiscoMailAlias" = "gcc-fedramp-opstack@cisco.com", "cdo-gov:opstack:ApplicationName" = "Spaces", "cdo-gov:opstack:Environment" = "Prod", "cdo-gov:opstack:ResourceOwner" = "jagashet", deployed_fromdir = "bu-interlock-1/day-0", "cdo-gov:Opstack:DataClassificationFed" = "Direct Impact"})
  
  health_check {
    enabled             = true
    interval            = 30  # Interval between health checks (in seconds)
    timeout             = 5   # Timeout for each health check (in seconds)
    healthy_threshold   = 2   # Number of consecutive successful health checks to mark target as healthy
    unhealthy_threshold = 2   # Number of consecutive failed health checks to mark target as unhealthy
    path                = "/" # Endpoint path for health check
    port                = "traffic-port"  # Port to perform health check
    protocol            = "HTTP" # Protocol for health check
    matcher             = "403"
  }
depends_on = [aws_instance.my_ec2,aws_lb.Jenkins_Alb]
}

resource "aws_lb_listener" "jenkins_listener" {
  load_balancer_arn = aws_lb.Jenkins_Alb.arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.Jenkins_target_group.arn
  }
depends_on = [aws_lb_target_group.Jenkins_target_group]
}

resource "aws_lb_target_group_attachment" "example_attachment" {
  target_group_arn = aws_lb_target_group.Jenkins_target_group.arn
  target_id        = aws_instance.my_ec2.id
}
