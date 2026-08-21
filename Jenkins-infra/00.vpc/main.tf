module "vpc" {
    source = "../VPC_Module"
    project = var.project
    env = var.env

}