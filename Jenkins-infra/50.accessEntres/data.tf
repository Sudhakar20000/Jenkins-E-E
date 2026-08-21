data "aws_ssm_parameter" "eks_cluster_name" {
    name = "/${var.project}/${var.environment}/eks_cluster_name"
}

data "aws_ssm_parameter" "jenkins_agent_iam_role_arn" {
    name = "/${var.project}/${var.environment}/jenkins_agent_iam_role_arn"
}