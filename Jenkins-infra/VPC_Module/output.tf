output "az" {
    value = data.aws_availability_zones.available.names
}

output "vpc_id" {
    value = aws_vpc.main.id
}

output "frounttir_subnet_ids" {
    value = aws_subnet.frounttir[*].id
}

output "apptire_subnet_ids" {
    value = aws_subnet.apptire[*].id
}

output "dbtire_subnet_ids" {
    value = aws_subnet.dbtire[*].id
} 