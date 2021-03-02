

locals {

  # Application Details
  appName     = "app"
  appEnv      = "dev"

  # Infra Tags
  infraSource = "terraform"

  awsRegion = "us-west-1"

  awsRegion_2 = "us-east-1"

  azs             = ["${local.awsRegion}a", "${local.awsRegion}c"]

  appNameEnv = "${local.appName}-${local.appEnv}"
}

module "vpc" {
  source = "../../resources/vpc/"

  vpc_cidr    = "172.17.0.0/16"
  vpc_tenancy = "default"

  enable_dns_hostnames = true
  enable_dns_support = true

  vpc_name = "${local.appNameEnv}-vpc"
  infra_source = local.infraSource  
  
}

module "subnets" {
  source = "../../resources/vpc/subnets"

  vpc_id_mod = "${module.vpc.vpc_id}"

  azs             = local.azs

  public_subnets  = ["172.17.0.0/24", "172.17.1.0/24"]
  public_subnets_name    = ["${local.appNameEnv}-sub-pub-1", "${local.appNameEnv}-sub-pub-2"]

  private_subnets = ["172.17.2.0/24", "172.17.3.0/24"]
  private_subnets_name    = ["${local.appNameEnv}-sub-pri-1", "${local.appNameEnv}-sub-pri-2"]

  infra_source = local.infraSource  

  # create igw
  igw_name = ["${local.appNameEnv}-igw-1"]

  # create pub_rtb
  pub_rtb_1_name = "${local.appNameEnv}-pub-rtb-1"

  # create pri_rtb
  pri_rtb_1_name = "${local.appNameEnv}-pri-rtb-1"

  # create eip
  eip_name = "${local.appNameEnv}-eip"

  # create nat
  nat_name = "${local.appNameEnv}-nat"

  enable_nat_gateway = true
  
}

module "ec2" {
 source = "../../resource/ec2"

 instance_ami = "provide ami id"
 instance_type = "provide type of instance"
 infra_source = 
 instance_name = "provide instance name"
 key_name = "provide key name"
 public_subnet_id_1_mod = "provide subnet details"
 vpc_security_group_ids = "provide SG ID"

}


