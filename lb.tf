# Create Application Load Balancer for incoming traffic
resource "aws_lb" "nginx-docker-host-lb" {
  name               = "nginx-docker-host-lb"
  load_balancer_type = "application"
  internal           = false
  subnets            = [ module.vpc.public_subnets[0], module.vpc.public_subnets[1]]
  security_groups    = [ aws_security_group.nginx_sg.id ]
  tags               = { 
    name = "nginx-docker-host-lb"
  }
}

resource "aws_lb_listener" "lb_listener" {
    load_balancer_arn = aws_lb.nginx-docker-host-lb.arn
    protocol          = "HTTP"
    port              = 80
    default_action {
      type             = "forward"
      target_group_arn = aws_lb_target_group.lb_target_group.arn
    }
}

resource "aws_lb_target_group" "lb_target_group" {
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id  
}

resource "aws_lb_target_group_attachment" "tgr_attachment" {
    target_group_arn = aws_lb_target_group.lb_target_group.arn
    target_id        = aws_instance.nginx-docker-host.id
    port             = 80
}

output "lb_public_dns_name" {
  value = aws_lb.nginx-docker-host-lb.dns_name
}