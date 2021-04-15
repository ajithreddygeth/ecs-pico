provider "aws" {
  region      = "${var.region}"
  profile = "pico"
}

#ecs cluster

resource "aws_ecs_cluster" "test-ecs-cluster" {
    name = "${var.ecs_cluster}"
}

#ASG

resource "aws_autoscaling_group" "ecs-autoscaling-group" {
    name                        = "ecs-autoscaling-group"
    max_size                    = "${var.max_instance_size}"
    min_size                    = "${var.min_instance_size}"
    desired_capacity            = "${var.desired_capacity}"
    vpc_zone_identifier         = ["${var.prisub1_id}", "${var.prisub2_id}"]
    launch_configuration        = "${aws_launch_configuration.ecs-launch-configuration.name}"
    health_check_type           = "ELB"
  }


#ALB

resource "aws_alb" "ecs-load-balancer" {
    name                = "ecs-load-balancer"
    security_groups     = ["${aws_security_group.test_public_sg.id}"]
    subnets             = ["${var.pubsub1_id}", "${var.pubsub2_id}"]

    tags {
      Name = "ecs-load-balancer"
    }
}

resource "aws_alb_target_group" "ecs-target-group" {
    name                = "ecs-target-group"
    port                = "80"
    protocol            = "HTTP"
    vpc_id              = "${var.vpc_id}"

    health_check {
        healthy_threshold   = "5"
        unhealthy_threshold = "2"
        interval            = "30"
        matcher             = "200"
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = "5"
    }

    tags {
      Name = "ecs-target-group"
    }
}

resource "aws_alb_listener" "alb-listener" {
    load_balancer_arn = "${aws_alb.ecs-load-balancer.arn}"
    port              = "80"
    protocol          = "HTTP"

    default_action {
        target_group_arn = "${aws_alb_target_group.ecs-target-group.arn}"
        type             = "forward"
    }
}

# insrance role
resource "aws_iam_role" "ecs-instance-role" {
    name                = "ecs-instance-role"
    path                = "/"
    assume_role_policy  = "${data.aws_iam_policy_document.ecs-instance-policy.json}"
}

data "aws_iam_policy_document" "ecs-instance-policy" {
    statement {
        actions = ["sts:AssumeRole"]

        principals {
            type        = "Service"
            identifiers = ["ec2.amazonaws.com"]
        }
    }
}

resource "aws_iam_role_policy_attachment" "ecs-instance-role-attachment" {
    role       = "${aws_iam_role.ecs-instance-role.name}"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs-instance-profile" {
    name = "ecs-instance-profile"
    path = "/"
    roles = ["${aws_iam_role.ecs-instance-role.id}"]
    provisioner "local-exec" {
      command = "sleep 10"
    }
}

#service role
resource "aws_iam_role" "ecs-service-role" {
    name                = "ecs-service-role"
    path                = "/"
    assume_role_policy  = "${data.aws_iam_policy_document.ecs-service-policy.json}"
}

resource "aws_iam_role_policy_attachment" "ecs-service-role-attachment" {
    role       = "${aws_iam_role.ecs-service-role.name}"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

data "aws_iam_policy_document" "ecs-service-policy" {
    statement {
        actions = ["sts:AssumeRole"]

        principals {
            type        = "Service"
            identifiers = ["ecs.amazonaws.com"]
        }
    }
}
# launch configuration 
resource "aws_launch_configuration" "ecs-launch-configuration" {
    name                        = "ecs-launch-configuration"
    image_id                    = "ami-0be13a99cd970f6a9"
    instance_type               = "t3.xlarge"
    iam_instance_profile        = "${aws_iam_instance_profile.ecs-instance-profile.id}"

    root_block_device {
      volume_type = "standard"
      volume_size = 100
      delete_on_termination = true
    }

    lifecycle {
      create_before_destroy = true
    }

    security_groups             = ["${aws_security_group.test_public_sg.id}"]
    associate_public_ip_address = "true"
    key_name                    = "${var.ecs_key_pair_name}"
    user_data                   = <<EOF
                                  #!/bin/bash
                                  echo ECS_CLUSTER=${var.ecs_cluster} >> /etc/ecs/ecs.config
                                  EOF
}

# service 

resource "aws_ecs_service" "test-ecs-service" {
  	name            = "test-ecs-service"
  	iam_role        = "${aws_iam_role.ecs-service-role.name}"
  	cluster         = "${aws_ecs_cluster.test-ecs-cluster.id}"
  	task_definition = "${aws_ecs_task_definition.webserver.family}:${max("${aws_ecs_task_definition.webserver.revision}", "${data.aws_ecs_task_definition.webserver.revision}")}"
  	desired_count   = 1

  	load_balancer {
    	target_group_arn  = "${aws_alb_target_group.ecs-target-group.arn}"
    	container_port    = 8081
    	container_name    = "webserver"
	}
}

# task definition 

data "aws_ecs_task_definition" "webserver" {
  task_definition = "${aws_ecs_task_definition.webserver.family}"
}

resource "aws_ecs_task_definition" "webserver" {
    family                = "webserver"
    container_definitions = <<DEFINITION
[
  {
    "name": "webserver",
    "image": "ajithreddydocker/hellowd:0.1",
    "essential": true,
    "portMappings": [
      {
        "containerPort": 8081,
        "hostPort": 80
      }
    ],
    "memory": 500,
    "cpu": 10
  }
]
DEFINITION
}

# sg

# ECS Instance Security group

resource "aws_security_group" "test_public_sg" {
    name = "test_public_sg"
    description = "Test public access security group"
    vpc_id = "${var.vpc_id}"

   ingress {
       from_port = 22
       to_port = 22
       protocol = "tcp"
       cidr_blocks = [
          "0.0.0.0/0"]
   }

   ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = [
          "0.0.0.0/0"]
   }

   ingress {
      from_port = 8080
      to_port = 8080
      protocol = "tcp"
      cidr_blocks = [
          "0.0.0.0/0"]
    }

   ingress {
      from_port = 0
      to_port = 0
      protocol = "tcp"
      cidr_blocks = [
         "${var.pubsub1_cidr}",
         "${var.pubsub2_cidr}",
         "${var.prisub1_cidr}",
         "${var.prisub2_cidr}"]
    }

    egress {
        # allow all traffic to private SN
        from_port = "0"
        to_port = "0"
        protocol = "-1"
        cidr_blocks = [
            "0.0.0.0/0"]
    }

    tags { 
       Name = "test_public_sg"
     }
}