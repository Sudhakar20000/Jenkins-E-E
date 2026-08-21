module "sg" {
    source = "../sg_module"
    count = length(var.sg_name)
    project = var.project
    env = var.env
    vpc_id = local.vpc_id
    sg_name = replace(var.sg_name[count.index], "_", "-")
}