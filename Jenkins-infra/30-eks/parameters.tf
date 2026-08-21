resource "aws_ssm_parameter" "eks_cluster_name" {
  name  = "/${var.project}/${var.env}/eks_cluster_name"
  type  = "String"
  value = module.eks.cluster_name
  overwrite = true
}

