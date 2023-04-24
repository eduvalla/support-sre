variable "vpc_id" {
  description = "VPC ID for cluster"
}

variable "db_subnet" {
  description = "DB subnet"
}

variable "ami" {
  default = "AWS ami id"
}

variable "tagprefix" {
  description = "Used in tags as a prefix from root module"
}
### Cockroach DB vars

variable "crdb_count" {
  type = number
  default = "1"
}

variable "crdb_ip" {
  type    = list(string)
  default = ["192.168.0.10"]
}

variable "crdb_size" {
  type    = string
  default = "t2.micro"
}


### Zookeeper vars

variable "zookeeper_size" {
  type = string
  default = "t2.micro"
}

variable "zookeeper_count" {
  type = number
  default = "3"
}

### Cassandra vars

variable "cassandra_size" {
  type = string
  default = "t2.micro"
}

variable "cassandra_count" {
  type = number
  default = "3"
}