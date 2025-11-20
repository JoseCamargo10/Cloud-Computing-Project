module "s3_bucket" {
    source = "./modules/s3"
}

resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "3-tier"
    }
}

module "internet_gateway" {
    source = "./modules/igw"
    vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "public_web_az1" {
    vpc_id              = aws_vpc.main.id
    cidr_block          = "10.0.0.0/24"
    availability_zone   = "us-east-1a"

    tags = {
        Name = "Public-Web-Subnet-AZ-1"
    }
}

resource "aws_subnet" "private_app_az1" {
    vpc_id              = aws_vpc.main.id
    cidr_block          = "10.0.10.0/24"
    availability_zone   = "us-east-1a"

    tags = {
        Name = "Private-App-Subnet-AZ-1"
    }
}

resource "aws_subnet" "private_db_az1" {
    vpc_id              = aws_vpc.main.id
    cidr_block          = "10.0.20.0/24"
    availability_zone   = "us-east-1a"

    tags = {
        Name = "Private-DB-Subnet-AZ-1"
    }
}

resource "aws_subnet" "public_web_az2" {
    vpc_id              = aws_vpc.main.id
    cidr_block          = "10.0.30.0/24"
    availability_zone   = "us-east-1b"

    tags = {
        Name = "Public-Web-Subnet-AZ-2"
    }
}

resource "aws_subnet" "private_app_az2" {
    vpc_id              = aws_vpc.main.id
    cidr_block          = "10.0.40.0/24"
    availability_zone   = "us-east-1b"

    tags = {
        Name = "Private-App-Subnet-AZ-2"
    }
}

resource "aws_subnet" "private_db_az2" {
    vpc_id              = aws_vpc.main.id
    cidr_block          = "10.0.50.0/24"
    availability_zone   = "us-east-1b"

    tags = {
        Name = "Private-DB-Subnet-AZ-2"
    }
}

resource "aws_nat_gateway" "nat_gw_az1" {
    subnet_id     = aws_subnet.public_web_az1.id

    tags = {
    Name = "NAT-GW-AZ1"
    }
    depends_on = [module.internet_gateway]
}

resource "aws_nat_gateway" "nat_gw_az2" {
    subnet_id     = aws_subnet.public_web_az2.id

    tags = {
    Name = "NAT-GW-AZ2"
    }
    depends_on = [module.internet_gateway]
}

module "security_group" {
    source              = "./modules/security_group"

    vpc_id = aws_vpc.main

}
resource "aws_vpc_security_group_ingress_rule" "allow_internet_to_lb_external" {
    security_group_id = module.security_group[internet_facing_lb_sg].id

    cidr_ipv4         = "0.0.0.0/0"
    ip_protocol       = "TCP"
    to_port           = 80 
}

resource "aws_vpc_security_group_ingress_rule" "allow_web_tier_from_external_lb" {
    security_group_id            = module.security_group[web_tier_sg].id

    referenced_security_group_id = module.security_group[internet_facing_lb_sg].id
    ip_protocol                  = "TCP"
    to_port                      = 80 
}

resource "aws_vpc_security_group_ingress_rule" "allow_internal_lb_from_web_tier" {
    security_group_id            = module.security_group[internal_lb_sg].id

    referenced_security_group_id = module.security_group[web_tier_sg].id
    ip_protocol                  = "TCP"
    to_port                      = 80 
}

resource "aws_vpc_security_group_ingress_rule" "allow_private_app_from_internal_lb" {
    security_group_id            = module.security_group[private_instance_sg].id

    referenced_security_group_id = module.security_group[internal_lb_sg].id
    ip_protocol                  = "TCP"
    to_port                      = 4000
}

resource "aws_vpc_security_group_ingress_rule" "allow_db_from_private_app" {
    security_group_id            = module.security_group[database_sg].id

    referenced_security_group_id = module.security_group[private_instance_sg].id
    ip_protocol                  = "TCP"
    to_port                      = 3306
}
# module "ec2_iam" {
#     source = "./modules/iam"
# }


////
# Llamada al módulo para un Rol de EC2
module "ec2_role" {
    source                = "./modules/iam_role"

    role_name             = var.ec2_role_name
    instance_profile_name = var.ec2_instance_profile_name
    attached_policies     = var.ec2_attached_policies

    # Política de confianza para EC2
    assume_role_policy_json = jsonencode({
        Version = "2012-10-17",
        Statement = [{
        Effect = "Allow",
        Principal = {
            Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
        }]
    })
}



