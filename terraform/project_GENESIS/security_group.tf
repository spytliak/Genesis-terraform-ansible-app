#-------------------------------------------------------------------
# Application
#-------------------------------------------------------------------
resource "aws_security_group" "app" {
  name        = "SG-APP-${var.project}-${var.env}"
  description = "Security Group for APP"
  vpc_id      = module.vpc_genesis.vpc_id # data.aws_vpc.default.id

  dynamic "ingress" {
    for_each = var.allow_port_list["app"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.ssh_cidr}", "${var.vpc_cidr}"]
  }
  ingress {
    description     = "allow alb"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${aws_security_group.alb.id}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    {
      Name = "SG-APP-${var.project}-${var.env}"
    }
  )
}

#-------------------------------------------------------------------
# RDS
#-------------------------------------------------------------------
resource "aws_security_group" "rds" {
  name        = "SG-RDS-${var.project}-${var.env}"
  description = "Security Group for RDS"
  vpc_id      = module.vpc_genesis.vpc_id # data.aws_vpc.default.id

  dynamic "ingress" {
    for_each = var.allow_port_list["rds"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["${var.vpc_cidr}"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    {
      Name = "SG-RDS-${var.project}-${var.env}"
    }
  )
}

#-------------------------------------------------------------------
# ALB APP
#-------------------------------------------------------------------
resource "aws_security_group" "alb" {
  name        = "SG-ALB-${var.project}-${var.env}"
  description = "Security Group for ALB"
  vpc_id      = module.vpc_genesis.vpc_id

  dynamic "ingress" {
    for_each = var.allow_port_list["alb"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    {
      Name = "SG-ALB-${var.project}-${var.env}"
    }
  )
}
