# TODO: How are we going to do ssh keys?
resource "aws_key_pair" "ibm_key" {
  public_key = "${file("~/.ssh/ibm_id_rsa.pub")}"
  provider   = aws
  key_name   = "ibm_rsa"
}

resource "aws_network_interface" "support_sre_vpc" {
#  subnet_id   = aws_subnet.support_sre_db_subnet.id
  subnet_id = "${var.db_subnet.id}"
  private_ips = var.crdb_ip
  tags = {
    Name = "primary_interface_crdb"
  }
}

#resource "aws_network_interface" "support_sre_zookeeper" {
#  subnet_id   = aws_subnet.support_sre_db_subnet.id
#  private_ips = ["192.168.0.15", "192.168.0.16", "192.168.0.17"]
#  tags = {
#    Name = "primary_interface_zookeeper"
#  }
#}

#resource "aws_network_interface" "support_sre_jumpbox_private" {
#  subnet_id   = aws_subnet.support_sre_eks_subnet.id
#  private_ips = ["192.168.1.10"]
#  tags = {
#    Name = "jumpbox_private_interface"
#  }
#}

#resource "aws_instance" "support_sre_jump_box" {
#  ami           = data.aws_ami.ubuntu_20_04.id
#  instance_type = "t2.micro"
#  network_interface {
#    device_index         = 0
#    network_interface_id = aws_network_interface.support_sre_jumpbox_private.id
#  }
#  tags = {
#    Name = "support_sre_jump_box"
#  }
#}

resource "aws_instance" "crdb" {
  ami           = var.ami.id
  instance_type = var.crdb_size
  count = var.crdb_count
  subnet_id = "${var.db_subnet.id}"

  tags = {
    Name = join("_", [var.tagprefix, "cockroachdb", count.index + 1])
  }

}

resource "aws_instance" "zookeeper" {
  ami           =  var.ami.id
  instance_type = var.crdb_size
#  vpc_security_group_ids = [aws_security_group.support_sre_ssh.id]
  count = var.zookeeper_count
  subnet_id = "${var.db_subnet.id}"

  tags = {
    Name = join("_", [var.tagprefix, "zookeeper", count.index + 1])
  }


}

resource "aws_instance" "cassandra" {
  ami           =  var.ami.id
  instance_type = var.cassandra_size
  #  vpc_security_group_ids = [aws_security_group.support_sre_ssh.id]
  count = var.cassandra_count
  subnet_id = "${var.db_subnet.id}"

  tags = {
    Name = join("_", [var.tagprefix, "cassandra", count.index + 1])
  }


}