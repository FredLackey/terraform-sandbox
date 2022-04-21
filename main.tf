terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.54"
    }
  }
}

provider "aws" {
  region = "us-west-1"
  access_key = ">> ACCESS CODE HERE <<"
  secret_key = ">> SECRET CODE HERE <<"
}

#region Roles
resource "aws_iam_role" "fredlackey_task_execution_role" {
  name = "fredlackey_task_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name = "fredlackey_task_execution_role"
  }
}
resource "aws_iam_role_policy_attachment" "fredlackey_task_execution_role_attach" {
  role       = aws_iam_role.fredlackey_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
#endregion

#region VPCs
resource "aws_vpc" "fredlackey_vpc" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "fredlackey_vpc"
  }
}
#endregion

#region Logging
resource "aws_cloudwatch_log_group" "fredlackey_vpc_logs" {
  name = "fredlackey_vpc_logs"
  tags = {
    Name = "fredlackey_vpc_logs"
  }
}
#endregion

#region Subnets
resource "aws_subnet" "public_subnet_a" {
  vpc_id            = aws_vpc.fredlackey_vpc.id
  cidr_block        = "10.10.1.0/25"
  availability_zone = "us-west-1c"
  tags = {
    Name = "public_subnet_a"
  }
}
resource "aws_subnet" "public_subnet_b" {
  vpc_id            = aws_vpc.fredlackey_vpc.id
  cidr_block        = "10.10.1.128/25"
  availability_zone = "us-west-1b"
  tags = {
    Name = "public_subnet_b"
  }
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id      = aws_vpc.fredlackey_vpc.id
  cidr_block  = "10.10.2.0/25"
  availability_zone = "us-west-1c"
  tags = {
    Name = "private_subnet_a"
  }
}
resource "aws_subnet" "private_subnet_b" {
  vpc_id      = aws_vpc.fredlackey_vpc.id
  cidr_block  = "10.10.2.128/25"
  availability_zone = "us-west-1b"
  tags = {
    Name = "private_subnet_b"
  }
}

resource "aws_subnet" "secure_subnet_a" {
  vpc_id      = aws_vpc.fredlackey_vpc.id
  cidr_block  = "10.10.3.0/25"
  availability_zone = "us-west-1c"
  tags = {
    Name = "secure_subnet_a"
  }
}
resource "aws_subnet" "secure_subnet_b" {
  vpc_id      = aws_vpc.fredlackey_vpc.id
  cidr_block  = "10.10.3.128/25"
  availability_zone = "us-west-1b"
  tags = {
    Name = "secure_subnet_b"
  }
}
#endregion

#region Gateways
resource "aws_internet_gateway" "fredlackey_vpc_igw" {
  vpc_id = aws_vpc.fredlackey_vpc.id
  tags = {
    Name = "fredlackey_vpc_igw"
  }
}

resource "aws_eip" "ngw_eip_a" {
}
resource "aws_nat_gateway" "fredlackey_vpc_ngw_a" {
  subnet_id     = aws_subnet.public_subnet_a.id
  allocation_id = aws_eip.ngw_eip_a.id
  depends_on    = [aws_internet_gateway.fredlackey_vpc_igw]
}

resource "aws_eip" "ngw_eip_b" {
}
resource "aws_nat_gateway" "fredlackey_vpc_ngw_b" {
  subnet_id     = aws_subnet.public_subnet_b.id
  allocation_id = aws_eip.ngw_eip_b.id
  depends_on    = [aws_internet_gateway.fredlackey_vpc_igw]
}
#endregion

#region Routes
resource "aws_route" "fredlackey_vpc_route" {
  route_table_id  = aws_vpc.fredlackey_vpc.main_route_table_id
  gateway_id      = aws_internet_gateway.fredlackey_vpc_igw.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table" "private_route_a" {
  vpc_id = aws_vpc.fredlackey_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.fredlackey_vpc_ngw_a.id
  }

  tags = {
    Name = "private_route_a"
  }

  depends_on = [
    aws_nat_gateway.fredlackey_vpc_ngw_a
  ]
}
resource "aws_route_table_association" "private_route_assoc_a" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private_route_a.id
}

resource "aws_route_table" "private_route_b" {
  vpc_id = aws_vpc.fredlackey_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.fredlackey_vpc_ngw_b.id
  }

  tags = {
    Name = "private_route_b"
  }

  depends_on = [
    aws_nat_gateway.fredlackey_vpc_ngw_b
  ]
}
resource "aws_route_table_association" "private_route_assoc_b" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.private_route_b.id
}

resource "aws_route_table" "secure_route_a" {
  vpc_id = aws_vpc.fredlackey_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.fredlackey_vpc_ngw_a.id
  }

  tags = {
    Name = "secure_route_a"
  }

  depends_on = [
    aws_nat_gateway.fredlackey_vpc_ngw_a
  ]
}
resource "aws_route_table_association" "secure_route_assoc_a" {
  subnet_id      = aws_subnet.secure_subnet_a.id
  route_table_id = aws_route_table.secure_route_a.id
}
resource "aws_route_table" "secure_route_b" {
  vpc_id = aws_vpc.fredlackey_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.fredlackey_vpc_ngw_b.id
  }

  tags = {
    Name = "secure_route_b"
  }

  depends_on = [
    aws_nat_gateway.fredlackey_vpc_ngw_b
  ]
}
resource "aws_route_table_association" "secure_route_assoc_b" {
  subnet_id      = aws_subnet.secure_subnet_b.id
  route_table_id = aws_route_table.secure_route_b.id
}
#endregion

#region Security Groups
resource "aws_security_group" "public_sg" {
  vpc_id      = aws_vpc.fredlackey_vpc.id

  name        = "public_sg"
  description = "public_sg"
  tags = {
    Name = "public_sg"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "out_all"
  }

  # ingress {
  #   protocol  = -1
  #   self      = true
  #   from_port = 0
  #   to_port   = 0
  #   description = "in_all"
  # }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    self        = "false"
    cidr_blocks = ["0.0.0.0/0"]
    description = "in_https"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    self        = "false"
    cidr_blocks = ["0.0.0.0/0"]
    description = "in_http"
  }

}
resource "aws_security_group" "private_sg" {
  vpc_id      = aws_vpc.fredlackey_vpc.id

  name        = "private_sg"
  description = "private_sg"
  tags = {
    Name = "private_sg"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "out_all"
  }

  # ingress {
  #   protocol  = -1
  #   self      = true
  #   from_port = 0
  #   to_port   = 0
  #   description = "in_all"
  # }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    self        = "false"
    cidr_blocks = [
      # "10.10.1.0/24",
      aws_subnet.public_subnet_a.cidr_block,
      aws_subnet.public_subnet_b.cidr_block
    ]
    description = "in_https"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    self        = "false"
    cidr_blocks = [
      # "10.10.10.0/24"
      aws_subnet.public_subnet_a.cidr_block,
      aws_subnet.public_subnet_b.cidr_block
    ]
    description = "in_http"
  }

}
resource "aws_security_group" "secure_sg" {
  vpc_id      = aws_vpc.fredlackey_vpc.id

  name        = "secure_sg"
  description = "secure_sg"
  tags = {
    Name = "secure_sg"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "out_all"
  }

  # ingress {
  #   protocol  = -1
  #   self      = true
  #   from_port = 0
  #   to_port   = 0
  #   description = "in_all"
  # }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    self        = "false"
    cidr_blocks = [
      # "10.10.20.0/24"
      aws_subnet.private_subnet_a.cidr_block,
      aws_subnet.private_subnet_b.cidr_block
    ]
    description = "in_https"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    self        = "false"
    cidr_blocks = [
      # "10.10.20.0/24"
      aws_subnet.private_subnet_a.cidr_block,
      aws_subnet.private_subnet_b.cidr_block
    ]
    description = "in_http"
  }

}
#endregion

#region Load Balancers
resource "aws_alb_target_group" "adminuxapi_targets" {
  name        = "adminuxapi-targets"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.fredlackey_vpc.id
  target_type = "ip"
 
  health_check {
   healthy_threshold   = "3"
   interval            = "30"
   protocol            = "HTTP"
   matcher             = "200"
   timeout             = "3"
   path                = "/"
   unhealthy_threshold = "2"
  }

  tags = {
    Name = "adminuxapi-targets"
  }  
}
resource "aws_alb_target_group" "studentuxapi_targets" {
  name        = "studentuxapi-targets"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.fredlackey_vpc.id
  target_type = "ip"
 
  health_check {
   healthy_threshold   = "3"
   interval            = "30"
   protocol            = "HTTP"
   matcher             = "200"
   timeout             = "3"
   path                = "/"
   unhealthy_threshold = "2"
  }

  tags = {
    Name = "studentuxapi-targets"
  }  
}
resource "aws_alb_target_group" "landing_targets" {
  name        = "landing-targets"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.fredlackey_vpc.id
  target_type = "ip"
 
  health_check {
   healthy_threshold   = "3"
   interval            = "30"
   protocol            = "HTTP"
   matcher             = "200"
   timeout             = "3"
   path                = "/"
   unhealthy_threshold = "2"
  }

  tags = {
    Name = "landing-targets"
  }  
}

resource "aws_lb" "public_lb" {
  name                = "public-lb"
  load_balancer_type  = "application"
  internal            = false
  security_groups     = [aws_security_group.public_sg.id]
  subnets             = [
    aws_subnet.public_subnet_a.id,
    aws_subnet.public_subnet_b.id
  ]
  enable_deletion_protection = false
  tags = {
    Name = "public-lb"
  }
}
resource "aws_alb_listener" "public_listener" {
  load_balancer_arn = aws_lb.public_lb.id
  port              = 80
  protocol          = "HTTP"
 
  default_action {
    # target_group_arn = aws_alb_target_group.landing_targets.id
    target_group_arn = aws_alb_target_group.studentuxapi_targets.id
    type             = "forward"
  }
}
resource "aws_alb_listener_rule" "adminuxapi_listener_rule" {
  listener_arn = aws_alb_listener.public_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.adminuxapi_targets.arn
  }

  condition {
    path_pattern {
      values = ["/adminuxapi*"]
    }
  }

  /**
      {
      name                          = "fredlackey-nginx-lab"
      listener_arn                  = module.alb_tg_listeners.aws_lb_listener[0].arn
      action_type                   = "forward"
      action_target_group_arn       = module.alb_tg.aws_lb_target_groups[1].arn
      condition_path_pattern_values = ["/web*"]
    },
    */

  # condition {
  #   host_header {
  #     values = ["example.com"]
  #   }
  # }
}
resource "aws_alb_listener_rule" "studentuxapi_listener_rule" {
  listener_arn = aws_alb_listener.public_listener.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.studentuxapi_targets.arn
  }

  condition {
    path_pattern {
      values = ["/studentuxapi*"]
    }
  }

  /**
      {
      name                          = "fredlackey-nginx-lab"
      listener_arn                  = module.alb_tg_listeners.aws_lb_listener[0].arn
      action_type                   = "forward"
      action_target_group_arn       = module.alb_tg.aws_lb_target_groups[1].arn
      condition_path_pattern_values = ["/web*"]
    },
    */

  # condition {
  #   host_header {
  #     values = ["example.com"]
  #   }
  # }
}
resource "aws_alb_listener_rule" "landing_listener_rule" {
  listener_arn = aws_alb_listener.public_listener.arn
  priority     = 300

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.landing_targets.arn
  }

  condition {
    path_pattern {
      values = ["/landing*"]
    }
  }

  /**
      {
      name                          = "fredlackey-nginx-lab"
      listener_arn                  = module.alb_tg_listeners.aws_lb_listener[0].arn
      action_type                   = "forward"
      action_target_group_arn       = module.alb_tg.aws_lb_target_groups[1].arn
      condition_path_pattern_values = ["/web*"]
    },
    */

  # condition {
  #   host_header {
  #     values = ["example.com"]
  #   }
  # }
}


resource "aws_lb" "private_lb" {
  name                = "private-lb"
  load_balancer_type  = "application"
  internal            = true
  security_groups     = [aws_security_group.private_sg.id]
  subnets             = [
    aws_subnet.private_subnet_a.id,
    aws_subnet.private_subnet_b.id
  ]
  enable_deletion_protection = false
  tags = {
    Name = "private-lb"
  }  
}
resource "aws_alb_target_group" "mgmtapi_targets" {
  name        = "mgmtapi-targets"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.fredlackey_vpc.id
  target_type = "ip"
 
  health_check {
   healthy_threshold   = "3"
   interval            = "30"
   protocol            = "HTTP"
   matcher             = "200"
   timeout             = "3"
   path                = "/"
   unhealthy_threshold = "2"
  }

  tags = {
    Name = "mgmtapi-targets"
  }  
}
resource "aws_alb_listener" "private_listener" {
  load_balancer_arn = aws_lb.private_lb.id
  port              = 80
  protocol          = "HTTP"
 
  default_action {
    target_group_arn = aws_alb_target_group.mgmtapi_targets.id
    type             = "forward"
  }
}


resource "aws_lb" "secure_lb" {
  name                = "secure-lb"
  load_balancer_type  = "application"
  internal            = true
  security_groups     = [aws_security_group.secure_sg.id]
  subnets             = [
    aws_subnet.secure_subnet_a.id,
    aws_subnet.secure_subnet_b.id
  ]
  enable_deletion_protection = false
  tags = {
    Name = "secure_lb"
  }  
}
resource "aws_alb_target_group" "dataapi_targets" {
  name        = "dataapi-targets"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.fredlackey_vpc.id
  target_type = "ip"
 
  health_check {
   healthy_threshold   = "3"
   interval            = "30"
   protocol            = "HTTP"
   matcher             = "200"
   timeout             = "3"
   path                = "/"
   unhealthy_threshold = "2"
  }

  tags = {
    Name = "secure-targets"
  }  
}
resource "aws_alb_listener" "secure_listener" {
  load_balancer_arn = aws_lb.secure_lb.id
  port              = 80
  protocol          = "HTTP"
 
  default_action {
    target_group_arn = aws_alb_target_group.dataapi_targets.id
    type             = "forward"
  }
}
#endregion

#region Instances
resource "aws_ecs_cluster" "landing_cluster" {
  name = "landing_cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}
resource "aws_ecs_task_definition" "landing_task" {
  family                        = "landing_task"
  network_mode                  = "awsvpc"
  requires_compatibilities      = ["FARGATE", "EC2"]
  cpu                           = 512
  memory                        = 2048
  execution_role_arn = aws_iam_role.fredlackey_task_execution_role.arn

  container_definitions         = jsonencode([
    {
      name      = "landing"
      image     = "nginxdemos/hello:latest"
      cpu       = 512
      memory    = 2048
      essential = true  # if true and if fails, all other containers fail. Must have at least one essential
      environment = [],
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/landing_task"
          awslogs-region        = "us-west-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}
resource "aws_ecs_service" "landing_service" {
  name              = "landing_service"
  cluster           = aws_ecs_cluster.landing_cluster.id
  task_definition   = aws_ecs_task_definition.landing_task.id
  desired_count     = 1
  launch_type       = "FARGATE"
  platform_version  = "LATEST"

  load_balancer {
    target_group_arn = aws_alb_target_group.landing_targets.arn
    container_name   = "landing"
    container_port   = "80"
  }

  network_configuration {
    assign_public_ip  = false
    security_groups   = [aws_security_group.public_sg.id]
    subnets           = [
      aws_subnet.public_subnet_a.id,
      aws_subnet.public_subnet_b.id
    ]
  }
  lifecycle {
    ignore_changes = [task_definition]
  }
}


resource "aws_ecs_cluster" "adminuxapi_cluster" {
  name = "adminuxapi_cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}
resource "aws_ecs_task_definition" "adminuxapi_task" {
  family                        = "adminuxapi_task"
  network_mode                  = "awsvpc"
  requires_compatibilities      = ["FARGATE", "EC2"]
  cpu                           = 512
  memory                        = 2048
  execution_role_arn = aws_iam_role.fredlackey_task_execution_role.arn

  container_definitions         = jsonencode([
    {
      name      = "adminuxapi"
      image     = "138563826014.dkr.ecr.us-west-1.amazonaws.com/complexapi:latest"
      cpu       = 512
      memory    = 2048
      essential = true  # if true and if fails, all other containers fail. Must have at least one essential
      environment = [
        {
          "name"  : "NODE_PORT", 
          "value" : "80"
        },
        {
          "name"  : "NODE_ALIAS", 
          "value" : "ADMIN_UX_API"
        },
        {
          "name"  : "NODE_BASE", 
          "value" : "adminuxapi"
        },        
        {
          "name"  : "NODE_ENV", 
          "value" : "development"
        },    
        # {
        #   "name"  : "UPSTREAM_MGMTAPI",
        #   "value" : aws_lb.private_lb.dns_name
        # }
      ],
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/adminuxapi_task"
          awslogs-region        = "us-west-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}
resource "aws_ecs_service" "adminuxapi_service" {
  name              = "adminuxapi_service"
  cluster           = aws_ecs_cluster.adminuxapi_cluster.id
  task_definition   = aws_ecs_task_definition.adminuxapi_task.id
  desired_count     = 1
  launch_type       = "FARGATE"
  platform_version  = "LATEST"

  load_balancer {
    target_group_arn = aws_alb_target_group.adminuxapi_targets.arn
    container_name   = "adminuxapi"
    container_port   = "80"
  }

  network_configuration {
    assign_public_ip  = false
    security_groups   = [aws_security_group.public_sg.id]
    subnets           = [
      aws_subnet.public_subnet_a.id,
      aws_subnet.public_subnet_b.id
    ]
  }
  lifecycle {
    ignore_changes = [task_definition]
  }
}


resource "aws_ecs_cluster" "studentuxapi_cluster" {
  name = "studentuxapi_cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}
resource "aws_ecs_task_definition" "studentuxapi_task" {
  family                        = "studentuxapi_task"
  network_mode                  = "awsvpc"
  requires_compatibilities      = ["FARGATE", "EC2"]
  cpu                           = 512
  memory                        = 2048
  execution_role_arn = aws_iam_role.fredlackey_task_execution_role.arn

  container_definitions         = jsonencode([
    {
      name      = "studentuxapi"
      image     = "138563826014.dkr.ecr.us-west-1.amazonaws.com/complexapi:latest"
      cpu       = 512
      memory    = 2048
      essential = true  # if true and if fails, all other containers fail. Must have at least one essential
      environment = [
        {
          "name"  : "NODE_PORT", 
          "value" : "80"
        },
        {
          "name"  : "NODE_ALIAS", 
          "value" : "STUDENT_UX_API"
        },
        {
          "name"  : "NODE_BASE", 
          "value" : "studentuxapi"
        },        
        {
          "name"  : "NODE_ENV", 
          "value" : "development"
        },    
        # {
        #   "name"  : "UPSTREAM_MGMTAPI",
        #   "value" : aws_lb.private_lb.dns_name
        # }
      ],
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/studentuxapi_task"
          awslogs-region        = "us-west-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}
resource "aws_ecs_service" "studentuxapi_service" {
  name              = "studentuxapi_service"
  cluster           = aws_ecs_cluster.studentuxapi_cluster.id
  task_definition   = aws_ecs_task_definition.studentuxapi_task.id
  desired_count     = 1
  launch_type       = "FARGATE"
  platform_version  = "LATEST"

  load_balancer {
    target_group_arn = aws_alb_target_group.studentuxapi_targets.arn
    container_name   = "studentuxapi"
    container_port   = "80"
  }

  network_configuration {
    assign_public_ip  = false
    security_groups   = [aws_security_group.public_sg.id]
    subnets           = [
      aws_subnet.public_subnet_a.id,
      aws_subnet.public_subnet_b.id
    ]
  }
  lifecycle {
    ignore_changes = [task_definition]
  }
}


resource "aws_ecs_cluster" "mgmtapi_cluster" {
  name = "mgmtapi_cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}
resource "aws_ecs_task_definition" "mgmtapi_task" {
  family                        = "mgmtapi_task"
  network_mode                  = "awsvpc"
  requires_compatibilities      = ["FARGATE", "EC2"]
  cpu                           = 512
  memory                        = 2048
  execution_role_arn = aws_iam_role.fredlackey_task_execution_role.arn

  container_definitions         = jsonencode([
    {
      name      = "mgmtapi"
      image     = "138563826014.dkr.ecr.us-west-1.amazonaws.com/complexapi:latest"
      cpu       = 512
      memory    = 2048
      essential = true  # if true and if fails, all other containers fail. Must have at least one essential
      environment = [
        {
          "name"  : "NODE_PORT", 
          "value" : "80"
        },
        {
          "name"  : "NODE_ALIAS", 
          "value" : "MGMTAPI"
        },
        # {
        #   "name"  : "NODE_BASE", 
        #   "value" : "mgmtapi"
        # },    
        {
          "name"  : "NODE_ENV", 
          "value" : "development"
        },    
        {
          "name"  : "UPSTREAM_DATAAPI",
          "value" : aws_lb.secure_lb.dns_name
        }
      ],
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/mgmtapi_task"
          awslogs-region        = "us-west-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}
resource "aws_ecs_service" "mgmtapi_service" {
  name              = "mgmtapi_service"
  cluster           = aws_ecs_cluster.mgmtapi_cluster.id
  task_definition   = aws_ecs_task_definition.mgmtapi_task.id
  desired_count     = 1
  launch_type       = "FARGATE"
  platform_version  = "LATEST"

  load_balancer {
    target_group_arn = aws_alb_target_group.mgmtapi_targets.arn
    container_name   = "mgmtapi"
    container_port   = "80"
  }

  network_configuration {
    assign_public_ip  = false
    security_groups   = [aws_security_group.private_sg.id]
    subnets           = [
      aws_subnet.private_subnet_a.id,
      aws_subnet.private_subnet_b.id
    ]
  }
  lifecycle {
    ignore_changes = [task_definition]
  }
}


resource "aws_ecs_cluster" "dataapi_cluster" {
  name = "dataapi_cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}
resource "aws_ecs_task_definition" "dataapi_task" {
  family                        = "dataapi_task"
  network_mode                  = "awsvpc"
  requires_compatibilities      = ["FARGATE", "EC2"]
  cpu                           = 512
  memory                        = 2048
  execution_role_arn = aws_iam_role.fredlackey_task_execution_role.arn

  container_definitions         = jsonencode([
    {
      name      = "dataapi"
      image     = "138563826014.dkr.ecr.us-west-1.amazonaws.com/complexapi:latest"
      cpu       = 512
      memory    = 2048
      essential = true  # if true and if fails, all other containers fail. Must have at least one essential
      environment = [
        {
          "name"  : "NODE_PORT", 
          "value" : "80"
        },
        {
          "name"  : "NODE_ALIAS", 
          "value" : "dataapi"
        }
      ],
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/dataapi_task"
          awslogs-region        = "us-west-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}
resource "aws_ecs_service" "dataapi_service" {
  name              = "dataapi_service"
  cluster           = aws_ecs_cluster.dataapi_cluster.id
  task_definition   = aws_ecs_task_definition.dataapi_task.id
  desired_count     = 1
  launch_type       = "FARGATE"
  platform_version  = "LATEST"

  load_balancer {
    target_group_arn = aws_alb_target_group.dataapi_targets.arn
    container_name   = "dataapi"
    container_port   = "80"
  }

  network_configuration {
    assign_public_ip  = false
    security_groups   = [aws_security_group.secure_sg.id]
    subnets           = [
      aws_subnet.secure_subnet_a.id,
      aws_subnet.secure_subnet_b.id,
    ]
  }
  lifecycle {
    ignore_changes = [task_definition]
  }
}
#endregion

output "public_url" {
  value = format("http://%s", aws_lb.public_lb.dns_name)
}