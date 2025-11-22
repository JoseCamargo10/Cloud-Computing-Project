resource "aws_launch_template" "this" {
    name_prefix   = var.name_prefix
    image_id      = var.ami_id 
    instance_type = var.instance_type

    iam_instance_profile {
        arn = var.iam_instance_profile_arn 
    }


    network_interfaces {
        associate_public_ip_address = var.associate_public_ip
        security_groups             = var.security_group_ids
    }
}

resource "aws_autoscaling_group" "this" {
    name                = "${var.name_prefix}-asg"
    
    vpc_zone_identifier = var.vpc_zone_identifier 
    desired_capacity    = var.asg_desired_capacity
    max_size            = var.asg_max_size
    min_size            = var.asg_min_size

    launch_template {
        id      = aws_launch_template.this.id
        version = "$Latest"
    }

    target_group_arns = var.target_group_arns 
}