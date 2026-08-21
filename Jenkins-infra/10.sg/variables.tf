variable "project" {
    type = string
    default = "flipkart"
}

variable "env" {
    type = string
    default = "dev"
}
variable "sg_name" {
    type = list
    default = [
        "mongodb", "redis", "mysql", "rabbitmq",
        "public_alb",
        "bastion",
        "eks_control_plane",
        "eks_node","jenkins", "jenkins_agent"
        
    ]

}