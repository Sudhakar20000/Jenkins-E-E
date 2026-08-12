locals {
  vpc_id = data.aws_vpc.default.id
  ami    = data.aws_ami.joindevops.id
  common_tags = { 
    Project   = var.project
    Terraform = true
  }
}