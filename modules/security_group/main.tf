resource "aws_security_group" "this" {
    name        = var.name
    description = var.description 
    vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_egress_rule" "allow_all_ipv4" {
    security_group_id = aws_security_group.this.id 

    cidr_ipv4         = "0.0.0.0/0"
    ip_protocol       = "-1" 
    description       = "Allow all outbound IPv4 traffic"
}

