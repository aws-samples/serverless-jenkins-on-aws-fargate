output efs_file_system_id {
  value       = aws_efs_file_system.this.id
  description = "The id of the efs file system"
}

output efs_file_system_dns_name {
  value       = aws_efs_file_system.this.dns_name
  description = "The dns name of the efs file system"
}

output efs_access_point_id {
  value       = aws_efs_access_point.this.id
  description = "The id of the efs access point"
}

output efs_security_group_id {
  value       = aws_security_group.efs_security_group.id
  description = "The id of the efs security group"
}

output efs_aws_backup_plan_name {
  value       = aws_backup_plan.this.*.name
  description = "The name of the aws backup plan used for EFS backups"
}

output efs_aws_backup_vault_name {
  value       = aws_backup_vault.this.*.name
  description = "The name of the aws backup vault used for EFS backups"
}