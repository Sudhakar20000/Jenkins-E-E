locals {
    eks_control_plane_sg_id = data.aws_ssm_parameter.eks_control_plane_sg_id.value
    eks_node_sg_id = data.aws_ssm_parameter.eks_node_sg_id.value
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    private_subnet_ids = split(",", data.aws_ssm_parameter.private_subnet_ids.value)
    common_tags = {
        Project = var.project
        Environment = var.env
        Name = "${var.project}-${var.env}"
    }
    common_name = "${var.project}-${var.env}"
}