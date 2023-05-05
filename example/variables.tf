variable route53_domain_name {
  type        = string
  description = "The domain"
  default     = "staging.dscpl.net"
}

variable route53_zone_id {
  type        = string
  description = <<EOF
The route53 zone id where DNS entries will be created. Should be the zone id
for the domain in the var route53_domain_name.
EOF
  default     = "Z00127123QLM4LWVF7RSG"
}

variable jenkins_dns_alias {
  type        = string
  description = <<EOF
The DNS alias to be associated with the deployed jenkins instance. Alias will
be created in the given route53 zone
EOF
  default     = "jenkins"
}

variable vpc_id {
  type        = string
  description = "The vpc id for where jenkins will be deployed"
  default     = "vpc-037167ad1292a15ca"
}

variable efs_subnet_ids {
  type        = list(string)
  description = "A list of subnets to attach to the EFS mountpoint. Should be private"
  default = ["subnet-039b7f0671156685f","subnet-0be179aba1c2c5c2e","subnet-0bd36c21b6fe54653"]
}

variable jenkins_controller_subnet_ids {
  type        = list(string)
  description = "A list of subnets for the jenkins controller fargate service. Should be private"
  default = ["subnet-039b7f0671156685f","subnet-0be179aba1c2c5c2e","subnet-0bd36c21b6fe54653"]
}

variable alb_subnet_ids {
  type        = list(string)
  description = "A list of subnets for the Application Load Balancer"
  default = ["subnet-04c11ff1dda8ec26b","subnet-00a33be38e5d8e2d6","subnet-0e0b250c708661ce9"]
}
