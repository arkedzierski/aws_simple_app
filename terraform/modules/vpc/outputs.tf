##################################################################################
# OUTPUT
##################################################################################

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "subnets_private_ids" {
  value = values(aws_subnet.subnet-prvate)[*].id
}

output "subnets_public_ids" {
  value = values(aws_subnet.subnet-public)[*].id
}

output "secgrp_ecs_id" {
  value = aws_security_group.sg-ecs.id
}

output "secgrp_lb_id" {
  value = aws_security_group.sg-lb.id
}

output "secgrp_psql_id" {
  value = aws_security_group.sg_psql.id
}

output "secgrp_bastion_ssh_id" {
  value = aws_security_group.sg-ssh-bastion.id
}
