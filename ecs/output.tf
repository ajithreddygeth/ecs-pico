output "region" {
  value = "${var.region}"
}


output "test_public_sg_id" {
  value = "${aws_security_group.test_public_sg.id}"
}

output "ecs-service-role-arn" {
  value = "${aws_iam_role.ecs-service-role.arn}"
}

output "ecs-instance-role-name" {
  value = "${aws_iam_role.ecs-instance-role.name}"
}

output "ecs-load-balancer-name" {
    value = "${aws_alb.ecs-load-balancer.name}"
}

output "ecs-target-group-arn" {
    value = "${aws_alb_target_group.ecs-target-group.arn}"
}