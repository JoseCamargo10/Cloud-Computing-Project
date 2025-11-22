resource "aws_db_subnet_group" "aurora_subnet_group" {
  subnet_ids = var.private_subnet_ids
  tags = {
    Name = "${var.db_name}-subnet-group"
  }
}

resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier      = "${var.db_name}-cluster"
  engine                  = "aurora-mysql"
  engine_version          = "8.0.mysql_aurora.3.08.2"
  database_name           = var.db_name
  master_username         = var.db_username
  master_password         = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.aurora_subnet_group.name
  vpc_security_group_ids  = var.vpc_security_group_ids
  skip_final_snapshot     = true
  backup_retention_period = 7
  preferred_backup_window = "07:00-09:00"

  tags = {
    Name = "${var.db_name}-cluster"
    Tier = "Database"
  }
}

resource "aws_rds_cluster_instance" "primary" {
  identifier              = "${var.db_name}-primary"
  cluster_identifier      = aws_rds_cluster.aurora_cluster.id
  engine                  = aws_rds_cluster.aurora_cluster.engine
  engine_version          = aws_rds_cluster.aurora_cluster.engine_version
  instance_class          = "db.t3.medium" 
  publicly_accessible     = false          
  db_subnet_group_name    = aws_db_subnet_group.aurora_subnet_group.name
  promotion_tier          = 0              

  tags = {
    Name = "${var.db_name}-primary"
  }
}

resource "aws_rds_cluster_instance" "replica" {
  identifier              = "${var.db_name}-replica"
  cluster_identifier      = aws_rds_cluster.aurora_cluster.id
  engine                  = aws_rds_cluster.aurora_cluster.engine
  engine_version          = aws_rds_cluster.aurora_cluster.engine_version
  instance_class          = "db.t3.medium"
  publicly_accessible     = false
  db_subnet_group_name    = aws_db_subnet_group.aurora_subnet_group.name
  promotion_tier          = 1              

  tags = {
    Name = "${var.db_name}-replica"
  }
}