#-----------------------------------------------------------------------
# Random password for RDS
#-----------------------------------------------------------------------
resource "random_password" "password_rds" {
  count            = var.rds["create_pass"] ? 1 : 0
  length           = 12
  special          = true
  override_special = "!$%&*()-_=+:?"
}

#-----------------------------------------------------------------------
# AWS RDS 
#-----------------------------------------------------------------------
resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "rds-subnet-group"
  description = "VPC Subnets for rds"
  subnet_ids  = module.vpc_genesis.private_subnet_ids

  tags = merge(
    var.common_tags,
    {
      Name = "RDS-subnet_group-${var.project}-${var.env}"
    }
  )

  depends_on = [
    module.vpc_genesis
  ]
}

resource "aws_db_instance" "rds" {
  count = var.rds["create"] ? 1 : 0

  identifier = "rds-${var.env}"

  engine              = "mysql"
  engine_version      = "8.0.29"
  instance_class      = "db.t3.micro"
  allocated_storage   = 5
  storage_type        = "gp2"
  skip_final_snapshot = true

  port     = var.rds["db_port"]
  db_name  = var.rds["db_name"]
  username = var.rds["db_user"]
  password = var.rds["create_pass"] ? random_password.password_rds[0].result : var.rds["db_pass"]

  availability_zone = data.aws_availability_zones.available.names[count.index]
  multi_az          = false

  backup_retention_period             = 0
  iam_database_authentication_enabled = false
  publicly_accessible                 = false

  vpc_security_group_ids = [
    aws_security_group.rds.id
  ]

  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.id

  tags = merge(
    var.common_tags,
    {
      Name = "RDS-${var.project}-${var.env}"
    }
  )

  depends_on = [
    random_password.password_rds,
    aws_db_subnet_group.rds_subnet_group
  ]
}
