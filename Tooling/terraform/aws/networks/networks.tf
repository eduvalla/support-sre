resource "aws_vpc" "this" {
  cidr_block           = "192.168.0.0/16"
  provider             = aws
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "Support SRE VPC"
  }
}

resource "aws_subnet" "support_sre_db_subnet" {
  cidr_block              = "192.168.0.0/24"
  vpc_id = aws_vpc.this.id
  availability_zone       = element(data.aws_availability_zones.azs.names, 0)
  map_public_ip_on_launch = true
  tags = {
    Name = "support_sre_db_subnet"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  provider = aws
  vpc_id = aws_vpc.this.id
}

resource "aws_subnet" "support_sre_eks_subnet" {
  cidr_block = "192.168.1.0/24"
  vpc_id = aws_vpc.this.id
  availability_zone = element(data.aws_availability_zones.azs.names, 0)
  tags = {
    Name = join("-", [var.tagprefix, "eks_subnet"])
  }
}

resource "aws_route_table" "route_table_db" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}
resource "aws_route_table_association" "subnet-association" {
  subnet_id      = aws_subnet.support_sre_db_subnet.id
  route_table_id = aws_route_table.route_table_db.id
}