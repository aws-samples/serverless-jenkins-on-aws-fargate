#!/usr/bin/env bash

# export TERRAFORM_WORKSPACE=jason-local-farm-runner
export TF_STATE_BUCKET="disciple-terraform-state-staging"
export TF_STATE_OBJECT_KEY="eu-west-1"
export TF_LOCK_DB="tf-lock-table"
export AWS_REGION="eu-west-1"

PRIVATE_SUBNETS='[subnet-039b7f0671156685f","subnet-0be179aba1c2c5c2e","subnet-0bd36c21b6fe54653"]'
PUBLIC_SUBNETS='["subnet-04c11ff1dda8ec26b","subnet-00a33be38e5d8e2d6","subnet-0e0b250c708661ce9"]'

export TF_VAR_route53_zone_id="Z00127123QLM4LWVF7RSG"
export TF_VAR_route53_domain_name="staging.dscpl.net"
export TF_VAR_vpc_id="vpc-037167ad1292a15ca"
export TF_VAR_efs_subnet_ids=${PRIVATE_SUBNETS}
export TF_VAR_jenkins_controller_subnet_ids=${PRIVATE_SUBNETS}
export TF_VAR_alb_subnet_ids=${PUBLIC_SUBNETS}
export TF_VAR_jenkins_dns_alias="jenkins"