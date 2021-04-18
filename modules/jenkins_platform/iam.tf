// EFS 
data "aws_iam_policy_document" efs_resource_policy {
  statement {
    effect = "Allow"
    actions = [
      "elasticfilesystem:ClientRootAccess",
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite"
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:root"]
    }

   resources = [
     "arn:aws:elasticfilesystem:${local.region}:${local.account_id}:file-system/${aws_efs_file_system.this.id}"
   ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["true"]
    }
  }
}


resource "aws_efs_file_system_policy" this {
  file_system_id = aws_efs_file_system.this.id
  policy         = data.aws_iam_policy_document.efs_resource_policy.json
}

// ECR
data "aws_iam_policy_document" ecr_resource_policy {
  statement {
    effect = "Allow"
    actions = [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability",
                "ecr:PutImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:DescribeRepositories",
                "ecr:GetRepositoryPolicy",
                "ecr:ListImages",
                "ecr:DeleteRepository",
                "ecr:BatchDeleteImage",
                "ecr:SetRepositoryPolicy",
                "ecr:DeleteRepositoryPolicy"
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:root"]
    }
  }

}

resource "aws_ecr_repository_policy" "this" {
  repository = aws_ecr_repository.jenkins_controller.name
  policy     = data.aws_iam_policy_document.ecr_resource_policy.json
}


// Backup
data "aws_iam_policy_document" "aws_backup_assume_policy" {
  count = var.efs_enable_backup ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" aws_backup_role {
  count = var.efs_enable_backup ? 1 : 0

  name               = "${var.name_prefix}-backup-role"
  assume_role_policy = data.aws_iam_policy_document.aws_backup_assume_policy[count.index].json
}

resource "aws_iam_role_policy_attachment" backup_role_policy {
  count = var.efs_enable_backup ? 1 : 0

  role       = aws_iam_role.aws_backup_role[count.index].id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}


// Jenkins
data "aws_iam_policy_document" ecs_assume_policy {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" ecs_execution_policy {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" ecs_execution_role {
  name               = "${var.name_prefix}-ecs-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_policy.json
  tags               = var.tags
}

resource "aws_iam_policy" ecs_execution_policy {
  name   = "${var.name_prefix}-ecs-execution-policy"
  policy = data.aws_iam_policy_document.ecs_execution_policy.json
}

resource "aws_iam_role_policy_attachment" ecs_execution {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = aws_iam_policy.ecs_execution_policy.arn
}

data "aws_iam_policy_document" jenkins_controller_task_policy {
  statement {
    effect = "Allow"
    actions = [
      "ecs:ListContainerInstances"
    ]
    resources = [aws_ecs_cluster.jenkins_controller.arn, aws_ecs_cluster.jenkins_agents.arn]
  }
  statement {
    effect = "Allow"
    actions = [
      "ecs:RunTask"
    ]
    condition {
      test     = "ArnEquals"
      variable = "ecs:cluster"
      values = [
          aws_ecs_cluster.jenkins_controller.arn,
          aws_ecs_cluster.jenkins_agents.arn
      ]
    }
    resources = ["arn:aws:ecs:${local.region}:${local.account_id}:task-definition/*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "ecs:StopTask",
      "ecs:DescribeTasks"
    ]
    condition {
      test     = "ArnEquals"
      variable = "ecs:cluster"
      values = [
          aws_ecs_cluster.jenkins_controller.arn,
          aws_ecs_cluster.jenkins_agents.arn
      ]
    }
    resources = ["arn:aws:ecs:${local.region}:${local.account_id}:task/*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "ssm:PutParameter",
      "ssm:GetParameter",
      "ssm:GetParameters"
    ]
    resources = ["arn:aws:ssm:${local.region}:${local.account_id}:parameter/jenkins*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt"
    ]
    resources = ["arn:aws:kms:${local.region}:${local.account_id}:alias/aws/ssm"]
  }
  statement {
    effect = "Allow"
    actions = [
      "iam:PassRole"
    ]
    resources = ["arn:aws:iam::${local.account_id}:role/*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["${aws_cloudwatch_log_group.jenkins_controller_log_group.arn}:*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
      "elasticfilesystem:ClientMount",
      "ecr:GetAuthorizationToken",
      "ecs:RegisterTaskDefinition",
      "ecs:ListClusters",
      "ecs:DescribeContainerInstances",
      "ecs:ListTaskDefinitions",
      "ecs:DescribeTaskDefinition",
      "ecs:DeregisterTaskDefinition"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "elasticfilesystem:ClientWrite",
      "elasticfilesystem:ClientRootAccess",
    ]
    resources = [
      aws_efs_file_system.this.arn,
    ]
  }
}

resource "aws_iam_policy" jenkins_controller_task_policy {
  name   = "${var.name_prefix}-controller-task-policy"
  policy = data.aws_iam_policy_document.jenkins_controller_task_policy.json
}

resource "aws_iam_role" jenkins_controller_task_role {
  name               = "${var.name_prefix}-controller-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_policy.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" jenkins_controller_task {
  role       = aws_iam_role.jenkins_controller_task_role.name
  policy_arn = aws_iam_policy.jenkins_controller_task_policy.arn
}


//CloudWatch
data "aws_iam_policy_document" "cloudwatch" {
  policy_id = "key-policy-cloudwatch"
  statement {
    sid = "Enable IAM User Permissions"
    actions = [
      "kms:*",
    ]
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:root"]
    }
    resources = ["*"]
  }
  statement {
    sid = "AllowCloudWatchLogs"
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = ["logs.${local.region}.amazonaws.com"]
    }
    resources = ["*"]
  }
}
