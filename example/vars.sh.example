#!/usr/bin/env bash

# export TERRAFORM_WORKSPACE=jason-local-farm-runner
export TF_STATE_BUCKET="tf-state-123456789012-eu-central-1"
export TF_STATE_OBJECT_KEY="serverless-jenkins.tfstate"
export TF_LOCK_DB="tf-lock-table"
export AWS_REGION=eu-central-1

PRIVATE_SUBNETS='["subnet-5d12c221","subnet-2178df6d","subnet-29452043"]'
PUBLIC_SUBNETS='["subnet-057d1da9eccbc21f5","subnet-0e191545ee05b0ad5","subnet-04d21adeb136042c1"]'

export TF_VAR_route53_zone_id="Z06494431NLTSXDDSOF83"
export TF_VAR_route53_domain_name="exampledomain.com"
export TF_VAR_vpc_id="vpc-za7f9bd0"
export TF_VAR_efs_subnet_ids=${PRIVATE_SUBNETS}
export TF_VAR_jenkins_controller_subnet_ids=${PRIVATE_SUBNETS}
export TF_VAR_alb_subnet_ids=${PUBLIC_SUBNETS}