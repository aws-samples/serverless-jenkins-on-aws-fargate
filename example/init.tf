/*
The deploy_example.sh script in this directory consumes variables in vars.sh and
then initializes Terraform. The values you see below will be over written by the
deploy_example.sh script and therefore do not need to be updated.
*/
terraform {
  required_version = ">= 0.13"
  backend "s3" {
    bucket = "willbeoverwritten"
    key    = "willbeoverwritten"
    encrypt = true
  }
}

provider "aws" {}
