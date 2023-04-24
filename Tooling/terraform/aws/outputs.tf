output "crdb_pri_ip" {
  value = {
  for instance in module.database_instances.crdb_instances :
  instance.id => instance.private_ip
  }
}

output "zookeeper_pri_ip" {
  value = {
  for instance in module.database_instances.zookeeper_instances :
  instance.id => instance.private_ip
  }
}

output "cassandra_pri_ip" {
  value = {
  for instance in module.database_instances.cassandra_instances :
  instance.id => instance.private_ip
  }
}

output "crdb_pub_ip" {
  value = {
  for instance in module.database_instances.crdb_instances :
  instance.id => instance.public_ip
  }
}

output "zookeeper_pub_ip" {
  value = {
  for instance in module.database_instances.zookeeper_instances :
  instance.id => instance.public_ip
  }
}

output "cassandra_pub_ip" {
  value = {
  for instance in module.database_instances.cassandra_instances :
  instance.id => instance.public_ip
  }
}

