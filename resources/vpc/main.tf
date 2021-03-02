/*
Reusable and configurable Elasticache module
*/

resource "aws_vpc" "vpc" {
  cidr_block       = "${var.vpc_cidr}"
  instance_tenancy = "${var.vpc_tenancy}"

  enable_dns_hostnames             = var.enable_dns_hostnames
  enable_dns_support               = var.enable_dns_support
  
  tags = {
    Name = "${var.vpc_name}"
    Source = "${var.infra_source}"
  }

}
