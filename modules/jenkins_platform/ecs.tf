// Jenkins Container Infra (Fargate)
resource "aws_ecs_cluster" jenkins_master {
  name               = "${var.name_prefix}-main"
  capacity_providers = ["FARGATE"]
  tags               = var.tags
  setting {
    name = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_cluster" jenkins_agents {
  name               = "${var.name_prefix}-spot"
  capacity_providers = ["FARGATE_SPOT"]
  tags               = var.tags
  setting {
    name = "containerInsights"
    value = "enabled"
  }
}

data "template_file" jenkins_master_container_def {
  template = file("${path.module}/templates/jenkins-master.json.tpl")

  vars = {
    name                = "${var.name_prefix}-master"
    jenkins_master_port = var.jenkins_master_port
    jnlp_port           = var.jenkins_jnlp_port
    source_volume       = "${var.name_prefix}-efs"
    jenkins_home        = "/var/jenkins_home"
    container_image     = aws_ecr_repository.jenkins_master.repository_url
    region              = local.region
    account_id          = local.account_id  
    log_group           = aws_cloudwatch_log_group.jenkins_master_log_group.name
    memory              = var.jenkins_master_memory
    cpu                 = var.jenkins_master_cpu
  }
}

resource "aws_cloudwatch_log_group" jenkins_master_log_group {
  name              = var.name_prefix
  retention_in_days = var.jenkins_master_task_log_retention_days

  tags = var.tags
}



resource "aws_ecs_task_definition" jenkins_master {
  family = var.name_prefix

  task_role_arn            = var.jenkins_master_task_role_arn != null ? var.jenkins_master_task_role_arn : aws_iam_role.jenkins_master_task_role.arn
  execution_role_arn       = var.ecs_execution_role_arn != null ? var.ecs_execution_role_arn : aws_iam_role.jenkins_master_task_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.jenkins_master_cpu
  memory                   = var.jenkins_master_memory
  container_definitions    = data.template_file.jenkins_master_container_def.rendered

  volume {
    name = "${var.name_prefix}-efs"

    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.this.id
      transit_encryption = "ENABLED"

      authorization_config {
        access_point_id = aws_efs_access_point.this.id
        iam             = "ENABLED"
      }
    }
  }

  tags = var.tags
}

resource "aws_ecs_service" jenkins_master {
  name = "${var.name_prefix}-master"

  task_definition  = aws_ecs_task_definition.jenkins_master.arn
  cluster          = aws_ecs_cluster.jenkins_master.id
  desired_count    = 1
  launch_type      = "FARGATE"
  platform_version = "1.4.0"

  // Assuming we cannot have more than one instance at a time. Ever. 
  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0
  
  
  service_registries {
    registry_arn = aws_service_discovery_service.master.arn
    port =  var.jenkins_jnlp_port
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = "${var.name_prefix}-master"
    container_port   = var.jenkins_master_port
  }

  network_configuration {
    subnets          = var.jenkins_master_subnet_ids
    security_groups  = [aws_security_group.jenkins_master_security_group.id]
    assign_public_ip = false
  }

  depends_on = [aws_lb_listener.https]
}


resource "aws_service_discovery_private_dns_namespace" "master" {
  name = var.name_prefix
  vpc = var.vpc_id
  description = "Serverless Jenkins discovery managed zone."
}


resource "aws_service_discovery_service" "master" {
  name = "master"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.master.id
    routing_policy = "MULTIVALUE"
    dns_records {
      ttl = 10
      type = "A"
    }

    dns_records {
      ttl  = 10
      type = "SRV"
    }
  }
  health_check_custom_config {
    failure_threshold = 5
  }
}
