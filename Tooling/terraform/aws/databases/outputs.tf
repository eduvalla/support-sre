output "crdb_instances" {
  value = aws_instance.crdb
}

output "zookeeper_instances" {
  value = aws_instance.zookeeper
}

output "cassandra_instances" {
  value = aws_instance.cassandra
}

#output "crdb_ip" {
#  value = {
#   for instance in aws_instance.crdb :
#        instance.id => instance.private_ip
#  }
#}
#
#output "zookeeper_ip" {
#  value = {
#  for instance in aws_instance.zookeeper :
#  instance.id => instance.private_ip
#  }
#}
#
#
#output "zookeeper_pub_ip" {
#  value = {
#  for instance in aws_instance.zookeeper :
#  instance.id => instance.public_ip
#  }
#}