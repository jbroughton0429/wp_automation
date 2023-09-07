resource "aws_ecs_cluster" "stateless" {
  name = "wordpress"
  tags = local.infra_tags
  
  setting {
    name = "containerInsights"
    value = "disabled"
    }
}

resource "aws_ecs_service" "wordpress" {
  name = "wordpress"
  cluster = aws_ecs_cluster.stateless.id
  task_definition = aws_ecs_task_definition.wordpress.arn
  desired_count = var.app_count
  launch_type   = "FARGATE"
  
  network_configuration {
    assign_public_ip = true
    security_groups = [aws_security_group.wordpress_task.id]
    subnets        = module.networking.public_subnets_id
  }
}


resource "aws_ecs_task_definition" "wordpress" {
    family	             = "wordpress-2"
    network_mode             = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    cpu                      = "512"
    memory                   = "1024"
    execution_role_arn       = "arn:aws:iam::913293700147:role/ecsTaskExecutionRole"
    task_role_arn            = "arn:aws:iam::913293700147:role/ecsTaskExecutionRole"
    tags                     = local.infra_tags

    runtime_platform {
      cpu_architecture       = "X86_64"
      operating_system_family = "LINUX"
    }
    
    container_definitions    = jsonencode(
        [
            {
                cpu              = 0
                environment      = [
                    {
                        name  = "WORDPRESS_DB_HOST"
                        value = aws_db_instance.wordpress.address
                    },
                    {
                        name  = "WORDPRESS_DB_NAME"
                        value = "wordpress"
                    },
                    {
                        name  = "WORDPRESS_DB_PASSWORD"
                        value = var.db_password
                    },
                    {
                        name  = "WORDPRESS_DB_USER"
                        value = var.db_user
                    },
                ]
                essential        = true
                image            = "913293700147.dkr.ecr.eu-central-1.amazonaws.com/wordpress:latest"
                name             = "wordpress"
                portMappings     = [
                    {
                        appProtocol   = "http"
                        containerPort = 80
                        hostPort      = 80
                        name          = "wordpress-80-tcp"
                        protocol      = "tcp"
                    },
                ]
            },
        ]
    )
}

