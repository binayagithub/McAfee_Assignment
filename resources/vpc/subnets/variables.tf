variable "vpc_id_mod" { }
variable "infra_source" { }
variable "public_subnets" {
    type = list(string)
    default = []
}
variable "azs" {
    type = list(string)
    default = []
}
variable "public_subnets_name" {
    type = list(string)
    default = []
}
variable "private_subnets" {
    type = list(string)
    default = []
}
variable "private_subnets_name" {
    type = list(string)
    default = []
}
variable "igw_name" {
    type = list(string)
    default = []
}
variable "pub_rtb_1_name" {
    type = string
}
variable "pri_rtb_1_name" {
    type = string
}
variable "eip_name" { }
variable "nat_name" { }
variable "enable_nat_gateway" {
    type = bool
    default = true
}