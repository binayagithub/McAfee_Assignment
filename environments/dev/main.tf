# mSyte-Prod-GP-Waveform-20200717
# mSyte-Prod-ETL-Cluster-GP_20200422
# mSyte-Prod-Rule-Cluster-201908051135
# mSyte-Prod-ETL-Cluster_Trend_m5axlarge_20200702
# mSyte-Prod-Streaming-Cluster-20200807


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

# module "vpc_peering" {
#   source = "../../resources/vpc/peering_connections"

#   accepcter_vpc_id = "vpc-002f0dc6642429cdc"
#   requester_vpc_id = "${module.vpc.vpc_id}"
#   peer_region = "us-east-1"
  
#   # common
#   infra_source = local.infraSource
#   vpc_peering_connection_name  = "${local.appNameEnv}-peering" 
    
# }

module "emr_cluster_ec2_role" {
  source = "../../resources/iam/roles"
  
  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "elasticmapreduce.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  # common
  infra_source = local.infraSource
  iam_role_name  = "${local.appNameEnv}-emr-cluster-ec2-role" 
  
}

module "emr_cluster_ec2_role_policy" {
  source = "../../resources/iam/policies"
  
  policy_name =  "${local.appNameEnv}-emr-s3-full-access" 
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
        "Sid": "VisualEditor0",
        "Effect": "Allow",
        "Action": "s3:*",
        "Resource": "*"
      }
  ]
}
EOF
}

module "emr_cluster_ec2_role_policy_att_1" {
  source = "../../resources/iam/role_policy_attachments"
  
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role"
  iam_role_name_mod =  "${module.emr_cluster_ec2_role.iam_role_name}"

}

module "emr_cluster_ec2_role_policy_att_2" {
  source = "../../resources/iam/role_policy_attachments"
  
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  iam_role_name_mod =  "${module.emr_cluster_ec2_role.iam_role_name}"

}

module "emr_cluster_ec2_role_policy_att_3" {
  source = "../../resources/iam/role_policy_attachments"
  
  policy_arn = "${module.emr_cluster_ec2_role_policy.iam_policy_arn}"
  iam_role_name_mod =  "${module.emr_cluster_ec2_role.iam_role_name}"

}

module "emr_cluster_service_role" {
  source = "../../resources/iam/roles"
  
  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "elasticmapreduce.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  # common
  infra_source = local.infraSource
  iam_role_name  = "${local.appNameEnv}-emr-cluster-service-role" 
  
}

module "emr_cluster_service_role_policy_att_1" {
  source = "../../resources/iam/role_policy_attachments"
  
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role"
  iam_role_name_mod =  "${module.emr_cluster_service_role.iam_role_name}"

}

module "security_groups_emr" {
  source = "../../resources/vpc/security_groups/emr"

  # commons
  infra_source = "terraform"

  vpc_id_mod = "${module.vpc.vpc_id}"

  emr_security_group_master_private_name = "${local.appNameEnv}-emr-master-private"
  emr_security_group_slave_private_name = "${local.appNameEnv}-emr-slave-private"

}

module "emr_cluster" {
  source = "../../resources/emr"
  
   # commons
  infra_source = "terraform"

  emr_cluster_name = "${local.appNameEnv}-emr"
  emr_release_label = "emr-5.30.0"
  emr_applications = ["Hadoop","Spark","Ganglia","Livy"]
  log_uri = "s3://molex-spark-s3-bucket/ETL-Streaming/prod/"

  private_subnet_id_1_mod = "${element(module.subnets.private_subnet_ids, 0)}"
  key_name = "iTest"

  emr_ec2_role_arn_mod = "EMR_EC2_DefaultRole" //"${module.iam_role.emr_autoscaling_role_arn}"
  emr_service_role_arn_mod = "EMR_DefaultRole" //"${module.iam_role.emr_service_role_arn}"
  emr_autoscaling_role_arn_mod = "EMR_AutoScaling_DefaultRole" //"${module.iam_role.emr_autoscaling_role_arn}"

  emr_cluster_master_name = "${local.appNameEnv}-emr-master"
  emr_cluster_master_instance_type = "m5.xlarge"
  emr_cluster_master_instance_count = "1"

  # emr_master_pri_id_mod = "${module.vpc.emr_master_pri_id}"
  # emr_slave_pri_id_mod = "${module.vpc.emr_slave_pri_id}"

  emr_master_ebs_size = "64"
  emr_master_ebs_type = "gp2"
  emr_master_ebs_volume_per_instance = "1"

  emr_cluster_core_name = "${local.appNameEnv}-emr-core"
  emr_cluster_core_instance_type = "m5.xlarge"
  emr_cluster_core_instance_count = "1"

  emr_core_ebs_size = "64"
  emr_core_ebs_type = "gp2"
  emr_core_ebs_volume_per_instance = "1"

}

module "cloudwatch" {
  source = "../../resources/cloudwatch"

  # commons
  infra_source = "terraform"

  log_group_name = "${local.appNameEnv}-msk-loggroup"
}

module "kms_key" {
  source = "../../resources/kms"

  # commons
  infra_source = "terraform"

  kms_key_name = "${local.appNameEnv}-kms-key"
}

module "security_groups" {
  source = "../../resources/vpc/security_groups"

  # commons
  infra_source = "terraform"

  vpc_id_mod = "${module.vpc.vpc_id}"

  security_group_public_name = "${local.appNameEnv}-public"
  security_group_private_name = "${local.appNameEnv}-private"

}


module "msk_cluster" {
  source = "../../resources/msk"

  # common
  infra_source = "${local.infraSource}"
  msk_cluster_name  = "${local.appNameEnv}-msk-cluster"
  msk_cluster_version = "2.2.1"
  msk_cluster_no_of_brokers = 2
  msk_cluster_instance_type = "kafka.m5.xlarge"
  msk_cluster_volume_size = 100
  sg_pri_1_id_mod = "${module.security_groups.security_group_private_id}"
  public_subnet_id_1_mod = "${element(module.subnets.public_subnet_ids, 0)}"
  private_subnet_id_1_mod = "${element(module.subnets.private_subnet_ids, 1)}"
  msk_config_arn_mod = "arn:aws:kafka:us-west-1:880111024226:configuration/msk-config-v-1/aa557e1f-2501-4347-8296-61c8138601f6-2"
  kms_key_arn_mod = "${module.kms_key.kms_key_arn}"
  msk_loggroup_name_mod = "${module.cloudwatch.loggroup_name}"

}

module "msk_lambda_full_access_role" {
  source = "../../resources/iam/roles"
  
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  # common
  infra_source = local.infraSource
  iam_role_name  = "${local.appNameEnv}-lambda-msk-full-access-role" 
  
}

module "msk_lambda_full_access_role_policy_att_1" {
  source = "../../resources/iam/role_policy_attachments"
  
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
  iam_role_name_mod =  "${module.msk_lambda_full_access_role.iam_role_name}"

}

module "msk_lambda_full_access_role_policy_att_2" {
  source = "../../resources/iam/role_policy_attachments"
  
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  iam_role_name_mod =  "${module.msk_lambda_full_access_role.iam_role_name}"

}

module "msk_lambda_full_access_role_policy_att_3" {
  source = "../../resources/iam/role_policy_attachments"
  
  policy_arn = "arn:aws:iam::aws:policy/AmazonVPCCrossAccountNetworkInterfaceOperations"
  iam_role_name_mod =  "${module.msk_lambda_full_access_role.iam_role_name}"

}

module "msk_lambda_full_access_role_policy_att_4" {
  source = "../../resources/iam/role_policy_attachments"
  
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  iam_role_name_mod =  "${module.msk_lambda_full_access_role.iam_role_name}"

}

module "msk_lambda_full_access_role_policy_att_5" {
  source = "../../resources/iam/role_policy_attachments"
  
  policy_arn = "arn:aws:iam::aws:policy/AWSXrayFullAccess"
  iam_role_name_mod =  "${module.msk_lambda_full_access_role.iam_role_name}"

}

module "lambda" {
  source = "../../resources/lambda"

  # commons
  infra_source = local.infraSource
  lambda_name  = "hello-lambda"
  lambda_msk_full_access_role_arn_mod = "${module.msk_lambda_full_access_role.iam_role_arn}"
  
  sg_pri_1_id_mod = "${module.security_groups.security_group_private_id}"
  public_subnet_id_1_mod = "${element(module.subnets.public_subnet_ids, 0)}"
  private_subnet_id_1_mod = "${element(module.subnets.private_subnet_ids, 1)}"

}

module "iot_policy" {
  source = "../../resources/iot/iot_policy"

  iot_policy_name  = "hello-lambda"
  iot_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "iot:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF

}

module "iot_cert" {
  source = "../../resources/iot/iot_cert"

}

module "iot_policy_att_1" {
  source = "../../resources/iot/iot_policy_attachments"
  
  iot_policy_name_mod = "${module.iot_policy.iot_policy_name}"
  iot_cert_arn_mod =  "${module.iot_cert.iot_cert_arn}"

}

# module "emr_cluster_ec2_role" {
#   source = "../../resources/iam/roles"
  
#   assume_role_policy = <<EOF
# {
#   "Version": "2008-10-17",
#   "Statement": [
#     {
#       "Sid": "",
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "elasticmapreduce.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# EOF

#   # common
#   infra_source = local.infraSource
#   iam_role_name  = "${local.appNameEnv}-emr-cluster-ec2-role" 
  
# }

# module "tag_based_resources_restrictions_policy" {
#   source = "../../resources/iam/policies"
  
#   policy_name =  "${local.appNameEnv}-emr-s3-full-access" 
#   policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Action": [
#                 "ec2:Describe*",
#                 "ec2:RunInstances"
#             ],
#             "Resource": [
#                 "*"
#             ],
#             "Effect": "Allow",
#             "Sid": "LaunchEC2Instances"
#         },
#         {
#             "Condition": {
#                 "StringEquals": {
#                     "ec2:ResourceTag/PrincipalId": "${aws:userid}"
#                 }
#             },
#             "Action": [
#                 "ec2:StopInstances",
#                 "ec2:StartInstances",
#                 "ec2:RebootInstances",
#                 "ec2:TerminateInstances"
#             ],
#             "Resource": [
#                 "*"
#             ],
#             "Effect": "Allow",
#             "Sid": "AllowActionsIfYouAreTheOwner"
#         }
#     ]
# }
# EOF
# }





# module "eks_cluster_role" {
#   source = "../../resources/iam/roles"
  
#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "eks.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# EOF

#   # common
#   infra_source = local.infraSource
#   iam_role_name  = "${local.appNameEnv}-eks-cluster-role" 
  
# }

# module "eks_cluster_role_policy_att_1" {
#   source = "../../resources/iam/role_policy_attachments"
  
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
#   iam_role_name_mod =  "${module.eks_cluster_role.iam_role_name}"

# }

# module "eks_cluster_role_policy_att_2" {
#   source = "../../resources/iam/role_policy_attachments"
  
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
#   iam_role_name_mod =  "${module.eks_cluster_role.iam_role_name}"

# }

# module "eks_worker_role" {
#   source = "../../resources/iam/roles"
  
#   assume_role_policy = <<POLICY
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "ec2.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# POLICY

#   # common
#   infra_source = local.infraSource
#   iam_role_name  = "${local.appNameEnv}-eks-worker-role" 
  
# }

# module "eks_worker_role_policy_att_1" {
#   source = "../../resources/iam/role_policy_attachments"
  
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
#   iam_role_name_mod =  "${module.eks_worker_role.iam_role_name}"

# }

# module "eks_worker_role_policy_att_2" {
#   source = "../../resources/iam/role_policy_attachments"
  
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
#   iam_role_name_mod =  "${module.eks_worker_role.iam_role_name}"

# }

# module "eks_worker_role_policy_att_3" {
#   source = "../../resources/iam/role_policy_attachments"
  
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
#   iam_role_name_mod =  "${module.eks_worker_role.iam_role_name}"

# }

# module "eks_cluster" {
#   source = "../../resources/eks/cluster"
  
#   eks_cluser_log_type = ["api", "audit"]
#   eks_cluster_role_arn_mod = "${module.eks_cluster_role.iam_role_arn}"

#   public_subnet_id_1_mod = "${element(module.subnets.public_subnet_ids, 0)}"
#   public_subnet_id_2_mod = "${element(module.subnets.public_subnet_ids, 1)}"

#   # common
#   infra_source = local.infraSource
#   eks_cluster_name  = "${local.appNameEnv}-eks-cluster" 

# }
