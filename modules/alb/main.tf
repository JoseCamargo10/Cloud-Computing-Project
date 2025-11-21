resource "aws_lb" "this" {
    name               = var.lb_name
    internal           = var.lb_internal
    load_balancer_type = "application"
    security_groups    = var.security_group_ids
    subnets            = var.subnet_ids
}

resource "aws_lb_target_group" "this" {
    name        = var.target_group_name
    port        = var.target_group_port
    protocol    = "HTTP"
    vpc_id      = var.vpc_id 
    target_type = "instance"
    
    health_check {
        path                = var.health_check_path
        protocol            = "HTTP"
        matcher             = var.health_check_matcher
        interval            = 30
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
    }
}