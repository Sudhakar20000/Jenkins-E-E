
data "aws_ami" "joindevops" {
  most_recent = true
  owners      = ["973714476881"]
  filter {
    name   = "name"
    values = ["Redhat-9-DevOps-Practice"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

data "aws_ssm_parameter" "vpc_id" {
    name = "/${var.project}/${var.env}/vpc_id"
}


data "http" "my_public_ip" {
  url = "https://ipv4.icanhazip.com"
}

data "aws_ssm_parameter" "jenkins_sg_id" {
    name = "/${var.project}/${var.env}/jenkins_sg_id"
}

data "aws_ssm_parameter" "jenkins_agent_sg_id" {
    name = "/${var.project}/${var.env}/jenkins_agent_sg_id"
}
data "aws_ssm_parameter" "public_subnet_ids" {
    name = "/${var.project}/${var.env}/frounttir_subnet_ids"
}
