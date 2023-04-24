output "support_sre_db_subnet" {
  value = aws_subnet.support_sre_db_subnet
}

output "vpc_id" {
  value = aws_vpc.this.id
}