#-------------------------------------------------------------------
# Create ssh key
#-------------------------------------------------------------------
resource "tls_private_key" "ssh-key" {
  count     = lookup(var.ssh_key, "install", false) ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ssh-key" {
  count      = lookup(var.ssh_key, "install", false) ? 1 : 0
  key_name   = var.ssh_key["name"]
  public_key = tls_private_key.ssh-key[0].public_key_openssh

  provisioner "local-exec" {
    when        = create
    on_failure  = continue
    interpreter = ["/bin/bash", "-c"]
    command     = "echo '${tls_private_key.ssh-key[0].private_key_pem}' > './${var.ssh_key["name"]}.pem' && chmod 600 terr  ./${var.ssh_key["name"]}.pem"
  }

  depends_on = [
    tls_private_key.ssh-key
  ]
}

resource "null_resource" "delete_ssh_key" {
  triggers = {
    ssh_key_name = var.ssh_key["name"]
  }

  provisioner "local-exec" {
    when        = destroy
    on_failure  = continue
    interpreter = ["/bin/bash", "-c"]
    command     = "test -f ./${self.triggers.ssh_key_name}.pem && rm ./${self.triggers.ssh_key_name}.pem"
  }

  depends_on = [
    aws_key_pair.ssh-key
  ]
}
