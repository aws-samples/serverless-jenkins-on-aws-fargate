variable route53_domain_name {
  type        = string
  description = "The domain"
}

variable route53_zone_id {
  type        = string
  description = <<EOF
The route53 zone id where DNS entries will be created. Should be the zone id
for the domain in the var route53_domain_name.
EOF
}

variable jenkins_dns_alias {
  type        = string
  description = <<EOF
The DNS alias to be associated with the deployed jenkins instance. Alias will
be created in the given route53 zone
EOF
  default     = "jenkins-controller"
}

variable vpc_id {
  type        = string
  description = "The vpc id for where jenkins will be deployed"
}

variable efs_subnet_ids {
  type        = list(string)
  description = "A list of subnets to attach to the EFS mountpoint. Should be private"
#   default = ["subnet-5d12c221","subnet-2178df6d","subnet-29452043"]
}

variable jenkins_controller_subnet_ids {
  type        = list(string)
  description = "A list of subnets for the jenkins controller fargate service. Should be private"
#   default = ["subnet-5d12c221","subnet-2178df6d","subnet-29452043"]
}

variable alb_subnet_ids {
  type        = list(string)
  description = "A list of subnets for the Application Load Balancer"
#   default = ["subnet-5d12c221","subnet-2178df6d","subnet-29452043"]
}