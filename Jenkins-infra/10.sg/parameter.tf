resource "aws_ssm_parameter" "sg_name" {
  count = length(var.sg_name)
  name        = "/${var.project}/${var.env}/${var.sg_name[count.index]}_sg_id"
  type        = "String"
  value       = module.sg[count.index].sg_id
  overwrite = true
}