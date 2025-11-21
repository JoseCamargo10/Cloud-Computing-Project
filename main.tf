module "s3_bucket" {
    source = "./modules/s3"
}

resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr
    tags = {
        Name = var.vpc_name
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

resource "aws_eip" "nat_gateway" {
    for_each = aws_subnet.public
    tags = {
        Name = "EIP-NAT-GW-${each.key}"
    }

    depends_on = [module.internet_gateway]
}

resource "aws_nat_gateway" "this" {
    for_each = aws_subnet.public
    allocation_id = aws_eip.nat_gateway[each.key].id 
    subnet_id = each.value.id 
    tags = {
        Name = "NAT-GW-${each.key}"
    }
}

module "security_group" {
    source      = "./modules/security_group"
    for_each    = var.security_groups

    vpc_id      = aws_vpc.main.id
    name        = each.value.name
    description = each.value.description

}

resource "aws_vpc_security_group_ingress_rule" "custom_ingress_rules" {
    for_each = var.ingress_rules

    # 1. SG que recibe el tráfico (Target)
    security_group_id = module.security_group[each.value.target_sg_key].id 

    # 2. Protocolo y Puertos
    ip_protocol = each.value.ip_protocol
    to_port     = each.value.to_port

    # 3. 🎯 LÓGICA CONDICIONAL: Origen del Tráfico
    
    # Si source_type es "cidr", se usa cidr_ipv4.
    cidr_ipv4 = each.value.source_type == "cidr" ? each.value.source_key_or_cidr : null

    # Si source_type es "sg_ref", se usa referenced_security_group_id,
    # transformando la clave del SG a su ID real.
    referenced_security_group_id = each.value.source_type == "sg_ref" ? module.security_group[each.value.source_key_or_cidr].id : null
}



# resource "aws_vpc_security_group_ingress_rule" "allow_lb_external_from_internet" {
#     security_group_id = module.security_group[public_lb_sg].id

#     cidr_ipv4         = "0.0.0.0/0"
#     ip_protocol       = "TCP"
#     to_port           = 80 
# }

# resource "aws_vpc_security_group_ingress_rule" "allow_web_tier_from_external_lb" {
#     security_group_id            = module.security_group[web_tier_sg].id

#     referenced_security_group_id = module.security_group[public_lb_sg].id
#     ip_protocol                  = "TCP"
#     to_port                      = 80 
# }

# resource "aws_vpc_security_group_ingress_rule" "allow_internal_lb_from_web_tier" {
#     security_group_id            = module.security_group[internal_lb_sg].id

#     referenced_security_group_id = module.security_group[web_tier_sg].id
#     ip_protocol                  = "TCP"
#     to_port                      = 80 
# }

# resource "aws_vpc_security_group_ingress_rule" "allow_private_app_from_internal_lb" {
#     security_group_id            = module.security_group[app_tier_sg].id

#     referenced_security_group_id = module.security_group[internal_lb_sg].id
#     ip_protocol                  = "TCP"
#     to_port                      = 4000
# }

# resource "aws_vpc_security_group_ingress_rule" "allow_db_from_private_app" {
#     security_group_id            = module.security_group[db_sg].id

#     referenced_security_group_id = module.security_group[app_tier_sg].id
#     ip_protocol                  = "TCP"
#     to_port                      = 3306
# }
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

module "load_balancers" {
    source = "./modules/alb"
    for_each = var.alb_configs

    # 1. Variables directas
    lb_name             = each.value.lb_name
    lb_internal         = each.value.lb_internal
    target_group_name   = each.value.target_group_name
    target_group_port   = each.value.target_group_port
    health_check_path   = each.value.health_check_path
    health_check_matcher = each.value.health_check_matcher
    vpc_id              = aws_vpc.main.id 
    
    # 2. Transformación de Security Groups (usan el mismo módulo)
    security_group_ids = [
        for key in each.value.security_group_keys : module.security_group[key].security_group_id
    ]
    subnet_ids = [
        for key in each.value.subnet_keys : 
        # Si lb_internal es true, usa aws_subnet.private. Si es false, usa aws_subnet.public.
        each.value.lb_internal ? aws_subnet.private[key].id : aws_subnet.public[key].id
    ]
}

resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = module.internet_gateway.internet_gateway_id
    }

    tags = {
        Name = "Public-RT"
    }
}

resource "aws_route_table_association" "public" {
    for_each       = aws_subnet.public

    subnet_id      = each.value.id
    route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table" "private_route_table_az1" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.this[web_az1].id
    }

    tags = {
        Name = "Private-RT-AZ1"
    }
}

resource "aws_route_table_association" "private_route_table_az1_association" {
    subnet_id      = aws_subnet.public[web_az1]
    route_table_id = aws_route_table.private_route_table_az1
}

resource "aws_route_table" "private_route_table_az2" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.this[web_az2].id
    }

    tags = {
        Name = "Private-RT-AZ2"
    }
}

resource "aws_route_table_association" "private_route_table_az2_association" {
    subnet_id      = aws_subnet.public[web_az2]
    route_table_id = aws_route_table.private_route_table_az2
}