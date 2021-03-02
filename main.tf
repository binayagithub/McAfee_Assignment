/*
This is the 'main' Terraform file. It calls all of our modules in order to
bring up the whole infrastructure
*/






provider "aws" {
  alias = "us-west-1"
  region                  = "us-west-1"
  shared_credentials_file = "C:\\Users\\<user_name>\\Documents\\test\\aws\\DevOps\\TF\\creds\\credentials"
  profile                 = "user-cred"
}


module "dev" {
  source = "./environments/dev"
  providers = {
    aws = "aws.us-west-1"
  }
}
# we can spin up another module like below
# module "stage" {
#   source = "./environments/stage"
#   providers = {
#     aws = "aws.us-west-2"
#   }
# }

