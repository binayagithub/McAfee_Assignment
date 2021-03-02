variable "instance_ami" { }
variable "instance_type" { }
variable "infra_source" { }
variable "instance_name" { }
variable "key_name" { }
variable "public_subnet_id_1_mod" { }
variable "vpc_security_group_ids" {
    type = list(string)
    default = []
}