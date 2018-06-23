variable "cluster-name" {
  default = "jobbatical-eks-cluster"
  type    = "string"
}

data "aws_availability_zones" "available" {}

resource "aws_vpc" "jobbatical-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = "${
    map(
     "Name", "jobbatical-vpc",
     "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

resource "aws_subnet" "jobbatical-az-1-subnets" {
  count = 2

  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = "${aws_vpc.jobbatical-vpc.id}"

  tags = "${
    map(
     "Name", "jobbatical-subnet-${data.aws_availability_zones.available.names[0]}-${count.index}",
     "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

resource "aws_subnet" "jobbatical-az-2-subnets" {
  count = 2

  availability_zone = "${data.aws_availability_zones.available.names[1]}"
  cidr_block        = "10.0.${count.index+2}.0/24"
  vpc_id            = "${aws_vpc.jobbatical-vpc.id}"

  tags = "${
    map(
     "Name", "jobbatical-subnet-${data.aws_availability_zones.available.names[1]}-${count.index+2}",
     "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

resource "aws_internet_gateway" "jobbatical-igw" {
  vpc_id = "${aws_vpc.jobbatical-vpc.id}"

  tags {
    Name = "jobbatical-igw"
  }
}

resource "aws_eip" "jobbatical-ngw-eip" {}

resource "aws_nat_gateway" "jobbatical-ngw" {
  allocation_id = "${aws_eip.jobbatical-ngw-eip.id}"
  subnet_id     = "${aws_subnet.jobbatical-az-1-subnets.*.id[0]}"

  tags {
    Name = "jobbatical-ngw"
  }
}

resource "aws_route_table" "jobbatical-public-rtb" {
  vpc_id = "${aws_vpc.jobbatical-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.jobbatical-igw.id}"
  }

  tags {
    Name = "jobbatical-public-rtb"
  }
}

resource "aws_route_table" "jobbatical-private-rtb" {
  vpc_id = "${aws_vpc.jobbatical-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.jobbatical-ngw.id}"
  }

  tags {
    Name = "jobbatical-private-rtb"
  }
}

resource "aws_route_table_association" "jobbatical-rtb-az-1-asc-1" {
  subnet_id      = "${aws_subnet.jobbatical-az-1-subnets.*.id[0]}"
  route_table_id = "${aws_route_table.jobbatical-public-rtb.id}"
}

resource "aws_route_table_association" "jobbatical-rtb-az-1-asc-2" {
  subnet_id      = "${aws_subnet.jobbatical-az-1-subnets.*.id[1]}"
  route_table_id = "${aws_route_table.jobbatical-private-rtb.id}"
}

resource "aws_route_table_association" "jobbatical-rtb-az-2-asc-1" {
  subnet_id      = "${aws_subnet.jobbatical-az-2-subnets.*.id[0]}"
  route_table_id = "${aws_route_table.jobbatical-public-rtb.id}"
}

resource "aws_route_table_association" "jobbatical-rtb-az-2-asc-2" {
  subnet_id      = "${aws_subnet.jobbatical-az-2-subnets.*.id[1]}"
  route_table_id = "${aws_route_table.jobbatical-private-rtb.id}"
}
