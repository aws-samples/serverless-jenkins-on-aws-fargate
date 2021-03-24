[
    {
      "name": "${name}",
      "image": "${container_image}",
      "cpu": ${cpu},
      "memory": ${memory},
      "memoryReservation": ${memory},
      "environment": [
        { "name" : "JAVA_OPTS", "value" : "-Djenkins.install.runSetupWizard=false" }
      ],
      "essential": true,
      "mountPoints": [
        {
          "containerPath": "${jenkins_home}",
          "sourceVolume": "${source_volume}"
        }
      ],
      "portMappings": [
        {
          "containerPort": ${jenkins_controller_port}
        },
        {
          "containerPort": ${jnlp_port}
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "${log_group}",
            "awslogs-region": "${region}",
            "awslogs-stream-prefix": "controller"
        }
      },
      "secrets": [
        {
          "name": "ADMIN_PWD",
          "valueFrom": "arn:aws:ssm:${region}:${account_id}:parameter/jenkins-pwd"
        }
      ]
    }
]
  