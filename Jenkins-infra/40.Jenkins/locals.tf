locals {
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  jenkins_sg_id = data.aws_ssm_parameter.jenkins_sg_id.value
  jenkins_agent_sg_id = data.aws_ssm_parameter.jenkins_agent_sg_id.value
  ami    = data.aws_ami.joindevops.id
  common_name = "${var.project}-${var.env}"
  public_subnet_id = split(",",data.aws_ssm_parameter.public_subnet_ids.value)[0]
  
  common_tags = { 
    Project   = var.project
    Env = var.env
    Terraform = true
  }
}