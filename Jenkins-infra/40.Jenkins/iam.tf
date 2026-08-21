resource "aws_iam_role" "jenkins_agent" {
  name = "${local.common_name}-jenkins_agent"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = merge(
    local.common_tags,
    {
        Name = "${local.common_name}-jenkins_agent"
    }
  )
}

resource "aws_iam_role_policy_attachment" "jenkins_agent" {
  role       = aws_iam_role.jenkins_agent.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_instance_profile" "jenkins_agent" {
  name = "${local.common_name}-jenkins_agent"
  role = aws_iam_role.jenkins_agent.name
}