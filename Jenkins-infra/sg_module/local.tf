locals {
    common_tags = {
    Name = local.common_name
    Project = var.project
    Env = var.env
    }
    common_name = "${var.project}-${var.env}-${var.sg_name}"
}