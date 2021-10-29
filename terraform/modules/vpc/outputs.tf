##################################################################################
# OUTPUT
##################################################################################

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "subnetA_prv_id" {
  value = aws_subnet.subnetA-prv.id
}

output "subnetB_prv_id" {
  value = aws_subnet.subnetB-prv.id
}

output "subnetA_public_id" {
  value = aws_subnet.subnetA-public.id
}

output "subnetB_public_id" {
  value = aws_subnet.subnetB-public.id
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
