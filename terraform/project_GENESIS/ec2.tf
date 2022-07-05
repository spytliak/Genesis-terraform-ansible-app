#-------------------------------------------------------------------
# EC2 - APP Server (server for flask api)
#-------------------------------------------------------------------
resource "aws_instance" "app" {
  count             = var.vm_node_count
  ami               = data.aws_ami.ubuntu_linux_latest.id
  instance_type     = var.instance_type["app"]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_security_group_ids = [
    aws_security_group.app.id
  ]
  subnet_id                   = module.vpc_genesis.public_subnet_ids[count.index]
  associate_public_ip_address = true
  user_data                   = templatefile("./templates/hostname.tpl", { hostname = "${var.host_name}-${format("%02d", count.index + 1)}-${var.env}" })
  key_name                    = var.ssh_key["install"] ? aws_key_pair.ssh-key[0].key_name : var.ssh_key["exist"]

  root_block_device {
    volume_size = "20"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.host_name}-${format("%02d", count.index + 1)}-${var.env}"
    }
  )

  depends_on = [
    aws_key_pair.ssh-key,
    aws_security_group.app
  ]
}

/*
resource "aws_ebs_volume" "app_volume" {
     availability_zone = data.aws_availability_zones.available.names[count.index]
     size              = 10
     type = "gp3"
     tags = merge(
      var.common_tags,
      { 
        Name = "app_volume-${var.project}"
      }
    )
}

resource "aws_volume_attachment" "app_volume" {
     device_name = "/dev/xvdb"
     volume_id   = aws_ebs_volume.app_volume.id
     instance_id = aws_instance.app[0].id
     skip_destroy = true
}
*/
