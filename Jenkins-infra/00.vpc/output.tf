output "vpc_id" {
    value = module.vpc.vpc_id
}

output "frounttir_subnet_ids" {
    value = module.vpc.frounttir_subnet_ids
}

output "apptire_subnet_ids" {
    value = module.vpc.apptire_subnet_ids
}

output "dbtire_subnet_ids" {
    value = module.vpc.dbtire_subnet_ids
}