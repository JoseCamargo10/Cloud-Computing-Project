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

resource "aws_subnet" "public" {
    for_each = var.public_subnets

    vpc_id              = aws_vpc.main.id
    cidr_block          = each.value.cidr_block
    availability_zone   = each.value.availability_zone

    tags = {
        Name = each.value.name
    }
}

resource "aws_subnet" "private" {
    for_each = var.private_subnets

    vpc_id              = aws_vpc.main.id
    cidr_block          = each.value.cidr_block
    availability_zone   = each.value.availability_zone

    tags = {
        Name = each.value.name
    }
}

resource "aws_nat_gateway" "nat_gw_az1" {
    subnet_id     = aws_subnet.public[web_az1].id

    tags = {
    Name = "NAT-GW-AZ1"
    }
    depends_on = [module.internet_gateway]
}

resource "aws_nat_gateway" "nat_gw_az2" {
    subnet_id     = aws_subnet.public[web_az2].id

    tags = {
    Name = "NAT-GW-AZ2"
    }
    depends_on = [module.internet_gateway]
}

module "security_group" {
    source      = "./modules/security_group"
    for_each    = var.security_groups

    vpc_id      = aws_vpc.main.id
    name        = each.value.name
    description = each.value.description

}

resource "aws_vpc_security_group_ingress_rule" "allow_lb_external_from_internet" {
    security_group_id = module.security_group[public_lb_sg].id

    cidr_ipv4         = "0.0.0.0/0"
    ip_protocol       = "TCP"
    to_port           = 80 
}

resource "aws_vpc_security_group_ingress_rule" "allow_web_tier_from_external_lb" {
    security_group_id            = module.security_group[web_tier_sg].id

    referenced_security_group_id = module.security_group[public_lb_sg].id
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
    security_group_id            = module.security_group[app_tier_sg].id

    referenced_security_group_id = module.security_group[internal_lb_sg].id
    ip_protocol                  = "TCP"
    to_port                      = 4000
}

resource "aws_vpc_security_group_ingress_rule" "allow_db_from_private_app" {
    security_group_id            = module.security_group[db_sg].id

    referenced_security_group_id = module.security_group[app_tier_sg].id
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

module "external_load_balancer" {
    source = "./modules/load_balancer"

    lb_name             = each.value.lb_name
    lb_internal         = each.value.lb_internal
    subnet_ids          = each.value.subnet_ids
    security_group_ids  = each.value.security_group_ids
    target_group_name   = each.value.target_group_name
    target_group_port   = each.value.target_group_port
    health_check_path   = each.value.health_check_path
    health_check_matcher = each.value.health_check_matcher
    
    # La VPC es una referencia global para todos los ALBs
    vpc_id              = aws_vpc.main.id 
}

module "internal_load_balancer" {
    # 🎯 Itera sobre el mapa de configuraciones
    for_each = var.alb_configs

    source = "./modules/load_balancer"

    # Mapeo de variables
    lb_name             = each.value.lb_name
    lb_internal         = each.value.lb_internal
    subnet_ids          = each.value.subnet_ids
    security_group_ids  = each.value.security_group_ids
    target_group_name   = each.value.target_group_name
    target_group_port   = each.value.target_group_port
    health_check_path   = each.value.health_check_path
    health_check_matcher = each.value.health_check_matcher
    
    # La VPC es una referencia global para todos los ALBs
    vpc_id              = aws_vpc.main.id 
}



# module "external_load_balancer" {
#     for_each = var.external_alb_configs # ⬅️ Usa la variable de externos

#     source = "./modules/load_balancer"

#     lb_name             = each.value.lb_name
#     lb_internal         = false # ⬅️ ¡Siempre false aquí!
#     target_group_name   = each.value.target_group_name
#     target_group_port   = each.value.target_group_port
#     health_check_path   = each.value.health_check_path
#     health_check_matcher = each.value.health_check_matcher
#     vpc_id              = aws_vpc.main.id 
    
#     # Transformación de claves a IDs (Asumiendo aws_subnet.public y module.security_group)
#     subnet_ids = [
#         for key in each.value.subnet_keys : aws_subnet.public[key].id
#     ]
#     security_group_ids = [
#         for key in each.value.security_group_keys : module.security_group[key].security_group_id
#     ]
# }

# module "internal_load_balancer" {
#     for_each = var.internal_alb_configs # ⬅️ Usa la variable de internos

#     source = "./modules/load_balancer"

#     lb_name             = each.value.lb_name
#     lb_internal         = true # ⬅️ ¡Siempre true aquí!
#     target_group_name   = each.value.target_group_name
#     target_group_port   = each.value.target_group_port
#     health_check_path   = each.value.health_check_path
#     health_check_matcher = each.value.health_check_matcher
#     vpc_id              = aws_vpc.main.id 
    
#     # Transformación de claves a IDs (Asumiendo aws_subnet.private y module.security_group)
#     subnet_ids = [
#         for key in each.value.subnet_keys : aws_subnet.private[key].id
#     ]
#     security_group_ids = [
#         for key in each.value.security_group_keys : module.security_group[key].security_group_id
#     ]
# }