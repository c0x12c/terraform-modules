output "id" {
  description = "The VPC ID"
  value       = aws_vpc.this.id
}

output "subnet_public" {
  description = "The public subnet information"
  value       = aws_subnet.public
}

output "subnet_private" {
  description = "The private subnet information"
  value       = aws_subnet.private
}

output "eip_nat_public_ip" {
  description = "The public IP of internet gateway"
  value       = try(aws_eip.nat[0].public_ip, null)
}

output "vpc_cidr_block" {
  description = "The VPC CIDR block"
  value       = aws_vpc.this.cidr_block
}

output "private_route_table_ids" {
  description = "List of private route table IDs"
  value       = tolist([for rt in aws_route_table.private : rt.id])
}

output "public_route_table_id" {
  description = "The public route table ID"
  value       = aws_route_table.public.id
}
