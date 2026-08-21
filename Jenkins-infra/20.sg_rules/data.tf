data "aws_ssm_parameter" "mongodb_sg_id" {
    name = "/${var.project}/${var.env}/mongodb_sg_id"
}

data "aws_ssm_parameter" "redis_sg_id" {
    name = "/${var.project}/${var.env}/redis_sg_id"
}

data "aws_ssm_parameter" "mysql_sg_id" {
    name = "/${var.project}/${var.env}/mysql_sg_id"
}

data "aws_ssm_parameter" "rabbitmq_sg_id" {
    name = "/${var.project}/${var.env}/rabbitmq_sg_id"
}

data "aws_ssm_parameter" "public_alb_sg_id" {
    name = "/${var.project}/${var.env}/public_alb_sg_id"
}

data "aws_ssm_parameter" "bastion_sg_id" {
    name = "/${var.project}/${var.env}/bastion_sg_id"
}

data "aws_ssm_parameter" "eks_control_plane_sg_id" {
    name = "/${var.project}/${var.env}/eks_control_plane_sg_id"
}

data "aws_ssm_parameter" "eks_node_sg_id" {
    name = "/${var.project}/${var.env}/eks_node_sg_id"
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