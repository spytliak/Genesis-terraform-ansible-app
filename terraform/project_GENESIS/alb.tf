#-----------------------------------------------------------------------
# Module
#-----------------------------------------------------------------------
# Terraform AWS Application Load Balancer (ALB)
#-----------------------------------------------------------------------
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.3.0"

  depends_on = [
    module.vpc_genesis,
    aws_db_instance.rds
  ]

  name                        = "ALB-${var.project}-${var.env}"
  load_balancer_type          = "application"
  vpc_id                      = module.vpc_genesis.vpc_id
  subnets                     = module.vpc_genesis.public_subnet_ids
  security_groups             = [aws_security_group.alb.id]
  enable_deletion_protection  = false
  listener_ssl_policy_default = "ELBSecurityPolicy-2016-08"

  target_groups = [
    {
      name                 = "alb-target-group-app-genesis"
      backend_protocol     = "HTTP"
      backend_port         = 5000
      target_type          = "instance"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/api/health-check/ok"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
      targets = {
        app = {
          target_id = aws_instance.app[0].id
          port      = 5000
        }
      }
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = merge(
    var.common_tags,
    {
      Name = "ALB_${var.project}-${var.env}"
    }
  )
}
