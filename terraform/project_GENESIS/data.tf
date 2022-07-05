#-------------------------------------------------------------------
# DATA
#-------------------------------------------------------------------
data "aws_region" "current" {}
data "aws_availability_zones" "available" {}

data "aws_ami" "ubuntu_linux_latest" {
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

data "aws_vpc" "default" {
  default = true
}

