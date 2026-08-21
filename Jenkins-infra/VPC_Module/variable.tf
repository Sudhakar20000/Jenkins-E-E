variable "project" {
    type = string
}

variable "env" {
    type = string
}

variable "vpc_tags" {
    type = map
    default = {}
}

variable "intgw_tags" {
    type = map
    default = {}
}

variable "cidrs_frounttir" {
    type = list
    default = [  "10.0.1.0/24" , "10.0.2.0/24" ]
}

variable "cidrs_apptire" {
    type = list
    default = [ "10.0.11.0/24" , "10.0.12.0/24" ]
}

variable "cidrs_dbtire" {
    type = list
    default = [ "10.0.21.0/24" , "10.0.22.0/24" ]
}

variable "subnet_frounttir_tags" {
    type = map
    default = {}
}

variable "subnet_apptire_tags" {
    type = map
    default = {}
}

variable "subnet_dbtire_tags" {
    type = map
    default = {}
}

variable "front_rout_tags" {
    type = map
    default = {}
}

variable "apptire_rout_tags" {
    type = map
    default = {}
}

variable "dbtire_rout_tags" {
    type = map
    default = {}
}

variable "eip_tags" {
    type = map
    default  = {}
}

variable "net_tags" {
    type = map
    default = { }
}
