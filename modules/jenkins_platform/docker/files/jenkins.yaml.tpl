jenkins:
    systemMessage: "Amazon Fargate Demo"
    numExecutors: 0
    remotingSecurity:
      enabled: true
    agentProtocols:
        - "JNLP4-connect"
    securityRealm:
        local:
            allowsSignup: false
            users:
                - id: ecsuser
                  password: \$${ADMIN_PWD}
    authorizationStrategy:
        globalMatrix:
            grantedPermissions:
                - "Overall/Read:anonymous"
                - "Job/Read:anonymous"
                - "View/Read:anonymous"
                - "Overall/Administer:authenticated"
    crumbIssuer: "standard"
    slaveAgentPort: 50000
    clouds:
        - ecs:
              allowedOverrides: "inheritFrom,label,memory,cpu,image"
              credentialsId: ""
              cluster: ${ecs_cluster_fargate_spot}
              name: "fargate-cloud-spot"
              regionName: ${cluster_region}
              retentionTimeout: 10
              jenkinsUrl: "http://${jenkins_cloud_map_name}:${jenkins_controller_port}"
              templates:
                  - assignPublicIp: true
                    cpu: "512"
                    image: "jenkins/inbound-agent"
                    label: "build-example-spot"
                    launchType: "FARGATE"
                    memory: 0
                    memoryReservation: 1024
                    networkMode: "awsvpc"
                    privileged: false
                    remoteFSRoot: "/home/jenkins"
                    securityGroups: ${agent_security_groups}
                    sharedMemorySize: 0
                    subnets: ${subnets}
                    templateName: "build-example"
                    uniqueRemoteFSRoot: false
        - ecs:
              allowedOverrides: "inheritFrom,label,memory,cpu,image"
              credentialsId: ""
              cluster: ${ecs_cluster_fargate}
              name: "fargate-cloud"
              regionName: ${cluster_region}
              retentionTimeout: 10
              jenkinsUrl: "http://${jenkins_cloud_map_name}:${jenkins_controller_port}"
              templates:
                  - assignPublicIp: true
                    cpu: "512"
                    image: "jenkins/inbound-agent"
                    label: "build-example"
                    launchType: "FARGATE"
                    memory: 0
                    memoryReservation: 1024
                    networkMode: "awsvpc"
                    privileged: false
                    remoteFSRoot: "/home/jenkins"
                    securityGroups: ${agent_security_groups}
                    sharedMemorySize: 0
                    subnets: ${subnets}
                    templateName: "build-example"
                    uniqueRemoteFSRoot: false
security:
  sSHD:
    port: -1
jobs:
  - script: >
      pipelineJob('Simple job critical task') {
        definition {
          cps {
            script('''
              pipeline {
                  agent {
                      ecs {
                          inheritFrom 'build-example'
                      }
                  }
                  stages {
                    stage('Test') {
                        steps {
                            script {
                                sh "echo this was executed on non spot instance"
                            }
                            sh 'sleep 120'
                            sh 'echo sleep is done'
                        }
                    }
                  }
              }'''.stripIndent())
              sandbox()
          }
        }
      }
  - script: >
      pipelineJob('Simple job non critical task') {
        definition {
          cps {
            script('''
              pipeline {
                  agent {
                      ecs {
                          inheritFrom 'build-example-spot'
                      }
                  }
                  stages {
                    stage('Test') {
                        steps {
                            script {
                                sh "echo this was executed on a spot instance"
                            }
                            sh 'sleep 120'
                            sh 'echo sleep is done'
                        }
                    }
                  }
              }'''.stripIndent())
              sandbox()
          }
        }
      }
