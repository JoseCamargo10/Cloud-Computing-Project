# --- Variables para Rol EC2 ---
ec2_role_name             = "app-server-role-dev"
ec2_instance_profile_name = "app-server-profile-dev"
ec2_attached_policies = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
]



vpc_cidr = "10.0.0.0/16"
vpc_name = "3-tier-vpc"

ingress_rules = {
    # Regla 1: ALB Externo desde Internet
    "lb_external_from_internet" = {
        target_sg_key      = "public_lb_sg" # SG que recibe
        source_type        = "cidr"
        source_key_or_cidr = "0.0.0.0/0"
        ip_protocol        = "TCP"
        to_port            = 80
    },
    
    # Regla 2: Web Tier desde ALB Externo
    "web_tier_from_external_lb" = {
        target_sg_key      = "web_tier_sg"
        source_type        = "sg_ref"
        source_key_or_cidr = "public_lb_sg" # SG que origina
        ip_protocol        = "TCP"
        to_port            = 80
    },
    
    # Regla 3: Internal LB desde Web Tier
    "internal_lb_from_web_tier" = {
        target_sg_key      = "internal_lb_sg"
        source_type        = "sg_ref"
        source_key_or_cidr = "web_tier_sg"
        ip_protocol        = "TCP"
        to_port            = 80
    },
    
    # Regla 4: App Tier desde Internal LB
    "app_from_internal_lb" = {
        target_sg_key      = "app_tier_sg"
        source_type        = "sg_ref"
        source_key_or_cidr = "internal_lb_sg"
        ip_protocol        = "TCP"
        to_port            = 4000
    },

    # Regla 5: DB Tier desde App Tier
    "db_from_app_tier" = {
        target_sg_key      = "db_sg"
        source_type        = "sg_ref"
        source_key_or_cidr = "app_tier_sg"
        ip_protocol        = "TCP"
        to_port            = 3306
    }
}

# ===============================================
# CONFIGURACIÓN DE SUBREDES PÚBLICAS
# ===============================================
public_subnets = {
    "web_az1" = {
        cidr_block        = "10.0.0.0/24"
        availability_zone = "us-east-1a"
        name              = "Public-Web-Subnet-AZ-1"
    },
    "web_az2" = {
        cidr_block        = "10.0.30.0/24"
        availability_zone = "us-east-1b"
        name              = "Public-Web-Subnet-AZ-2"
    }
}

# ===============================================
# CONFIGURACIÓN DE SUBREDES PRIVADAS
# ===============================================
private_subnets = {
    # Corresponde a private_app_az1 (10.0.10.0/24)
    "app_az1" = {
        cidr_block        = "10.0.10.0/24"
        availability_zone = "us-east-1a"
        name              = "Private-App-Subnet-AZ-1"
    },
    # Corresponde a private_db_az1 (10.0.20.0/24)
    "db_az1" = {
        cidr_block        = "10.0.20.0/24"
        availability_zone = "us-east-1a"
        name              = "Private-DB-Subnet-AZ-1"
    },
    # Corresponde a private_app_az2 (10.0.40.0/24)
    "app_az2" = {
        cidr_block        = "10.0.40.0/24"
        availability_zone = "us-east-1b"
        name              = "Private-App-Subnet-AZ-2"
    },
    # Corresponde a private_db_az2 (10.0.50.0/24)
    "db_az2" = {
        cidr_block        = "10.0.50.0/24"
        availability_zone = "us-east-1b"
        name              = "Private-DB-Subnet-AZ-2"
    }
}

security_groups = {
    "public_lb_sg" = {
        name        = "internet-facing-lb-sg"
        description = "SG para el ALB y tráfico público"
    },
    "web_tier_sg" = {
        name        = "web-tier-sg"
        description = "SG para la capa web pública"
    },
    "internal_lb_sg" = {
        name        = "private-internal-lb-sg"
        description = "SG para el ALB interno"
    },
    "app_tier_sg" = {
        name        = "app-tier-sg"
        description = "SG para la capa privada de aplicación"
    },
    "db_sg" = {
        name        = "db-sg"
        description = "SG para la capa de base de datos"
    }
}

alb_configs = {
    "web-alb-external" = {
        lb_name             = "web-alb-external"
        lb_internal         = false
        subnet_keys         = ["web_az1", "web_az2"] 
        security_group_keys = ["public_lb_sg"] 
        target_group_name   = "web-tier-tg"
        target_group_port   = 80
        health_check_path   = "/health"
    },
    "app-alb-internal" = {
        lb_name             = "app-alb-internal"
        lb_internal         = true 
        subnet_keys         = ["app_az1", "app_az2"] 
        security_group_keys = ["internal_lb_sg"] 
        target_group_name   = "app-tier-tg"
        target_group_port   = 4000
        health_check_path   = "/health"
    }
}

asg_configs = {
    "web_tier" = {
        ami_id                   = ""
        instance_type            = "t2.micro"
        associate_public_ip      = true                      # Necesita IP pública para el Internet Gateway
        security_group_keys      = ["web_tier_sg"]           # Asumiendo que esta es la clave de tu SG
        asg_desired_capacity     = 2
        asg_max_size             = 2
        asg_min_size             = 2
        subnet_keys              = ["web_az1", "web_az2"] 
        target_alb_key           = "web-alb-external" 
    },
    "app_tier" = {
        ami_id                   = ""
        instance_type            = "t2.micro"
        associate_public_ip      = false
        security_group_keys      = ["app_tier_sg"]
        asg_desired_capacity     = 2
        asg_max_size             = 2
        asg_min_size             = 2
        subnet_keys              = ["app_az1", "app_az2"] 
        target_alb_key           = "app-alb-internal" 
    }
}