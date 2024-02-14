resource "aws_lb" "nginx-docker-host-lb" {
  name = "nginx-docker-host-lb"
  load_balancer_type = "network"
  #internal = true
  subnets = [ aws_subnet.public_subnets[0].id]
  depends_on = [ aws_instance.nginx-docker-host ]
  security_groups = [ aws_security_group.instance_sg.id ]
  tags = {
    name = "nginx-docker-host-lb"
  }
  
}

resource "aws_lb_listener" "lb_listener" {
    load_balancer_arn = aws_lb.nginx-docker-host-lb.arn
    protocol = "TCP"
    port = 80
    default_action {
      type = "forward"
      target_group_arn = aws_lb_target_group.lb_target_group.arn
    }
  
}

resource "aws_lb_target_group" "lb_target_group" {
  port = 80
  protocol = "TCP"
  vpc_id = aws_vpc.main.id
  #depends_on = [ aws_lb.nginx-docker-host-lb ]
  health_check {
    path     = "/"
    protocol = "HTTP"
    port     = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "tgr_attachment" {
    target_group_arn = aws_lb_target_group.lb_target_group.arn
    target_id = aws_instance.nginx-docker-host.id
    port = 80
}

output "lb_public_dns_name" {
  value = aws_lb.nginx-docker-host-lb.dns_name
}