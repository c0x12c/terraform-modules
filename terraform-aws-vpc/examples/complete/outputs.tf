output "vpc_id" {
  value = module.aws_vpc.id
}

output "public_subnets" {
  value = module.aws_vpc.subnet_public
}

output "private_subnets" {
  value = module.aws_vpc.subnet_private
}

output "eip_nat_public_ips" {
  value = module.aws_vpc.eip_nat_public_ip
}

output "vpc_cidr_block" {
  value = module.aws_vpc.vpc_cidr_block
}
