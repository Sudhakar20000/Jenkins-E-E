locals{
    eks_cluster_name = data.aws_ssm_parameter.eks_cluster_name.value
    jenkins_agent_iam_role_arn = data.aws_ssm_parameter.jenkins_agent_iam_role_arn.value
}