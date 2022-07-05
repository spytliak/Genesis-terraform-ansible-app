#-------------------------------------------------------------------
# Create host file for ansible
#-------------------------------------------------------------------
resource "local_file" "host" {
  content = templatefile("./templates/ansible_host.tpl",
    {
      app_ip                       = aws_instance.app[0].public_ip
      ansible_ssh_user             = var.ssh_user_name
      ansible_ssh_private_key_file = "../terraform/project_GENESIS/${var.ssh_key["name"]}.pem"
    }
  )
  filename = "../../ansible/inventory/hosts.ini"

  depends_on = [
    aws_key_pair.ssh-key,
    aws_instance.app
  ]
}

#-------------------------------------------------------------------
# Create env file for ansible
#-------------------------------------------------------------------
resource "local_file" "env" {
  content = templatefile("./templates/env.tpl",
    {
      DB_USER = var.rds["db_user"]
      DB_PASS = var.rds["create_pass"] ? random_password.password_rds[0].result : var.rds["db_pass"]
      DB_HOST = aws_db_instance.rds[0].endpoint
      DB_NAME = var.rds["db_name"]
    }
  )
  filename = "../../ansible/roles/genesis_app/files/.env"

  depends_on = [
    aws_db_instance.rds
  ]
}

#-------------------------------------------------------------------
# Create var file with alb dns name for ansible
#-------------------------------------------------------------------
resource "local_file" "alb" {
  content = templatefile("./templates/ansible_vars_alb.tpl",
    {
      ALB_DNS_NAME = module.alb.lb_dns_name
    }
  )
  filename = "../../ansible/inventory/group_vars/all/alb.yaml"

  depends_on = [
    aws_db_instance.rds
  ]
}

#-------------------------------------------------------------------
# Provisioner ansible for create app on the server APP
#-------------------------------------------------------------------
resource "null_resource" "ansible" {
  count = var.ansible ? 1 : 0

  provisioner "local-exec" {
    when        = create
    on_failure  = continue
    interpreter = ["/bin/bash", "-c"]
    command     = "cd ../../ansible/ && ansible-playbook -i inventory/hosts.ini playbooks/genesis_app.yml"
  }

  depends_on = [
    local_file.host,
    local_file.env,
    local_file.alb
  ]
}