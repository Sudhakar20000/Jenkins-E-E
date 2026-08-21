resource "aws_eks_access_entry" "jenkins_agent" {
  cluster_name      = local.eks_cluster_name
  principal_arn     = local.jenkins_agent_iam_role_arn
  type              = "STANDARD"
}

resource "aws_eks_access_policy_association" "jenkins_agent" {
  cluster_name  = local.eks_cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = local.jenkins_agent_iam_role_arn

  access_scope {
    type       = "cluster"
  }
}