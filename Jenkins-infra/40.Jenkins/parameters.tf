resource "aws_ssm_parameter" "jenkins_agent_iam_role_arn" {
  name  = "/${var.project}/${var.env}/jenkins_agent_iam_role_arn"
  type  = "String"
  value = aws_iam_role.jenkins_agent.arn
  overwrite = true
}