resource "aws_ssm_parameter" "vpc_id" {
  name  = "/${var.project}/${var.env}/vpc_id"
  type  = "String"
  value = module.vpc.vpc_id
  overwrite = true
}

resource "aws_ssm_parameter" "frounttir_subnet_ids" {
  name  = "/${var.project}/${var.env}/frounttir_subnet_ids"
  type  = "String"
  value = join(",", module.vpc.frounttir_subnet_ids)
  overwrite = true
}

resource "aws_ssm_parameter" "apptire_subnet_ids" {
  name = "/${var.project}/${var.env}/apptire_subnet_ids"
  type  = "String"
  value = join(",", module.vpc.apptire_subnet_ids)
  overwrite = true
}

resource "aws_ssm_parameter" "dbtire_subnet_ids" {
  name = "/${var.project}/${var.env}/dbtire_subnet_ids"
  type  = "String"
  value = join(",", module.vpc.dbtire_subnet_ids)
  overwrite = true
}