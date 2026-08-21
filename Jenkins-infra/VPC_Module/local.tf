locals {
    common_tags = {
    Name = local.common_name
    Project = var.project
    Env = var.env
    }
    common_name = "${var.project}-${var.env}"
    availablez = slice(data.aws_availability_zones.available.names, 0, 2)
}