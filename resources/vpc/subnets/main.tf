resource "aws_subnet" "public" {
  vpc_id = "${var.vpc_id_mod}"
  count = "${length(var.public_subnets)}"
  cidr_block = "${element(var.public_subnets, count.index)}"
  availability_zone = "${element(var.azs, count.index)}"
  map_public_ip_on_launch = true

  tags = {
    Name = "${element(var.public_subnets_name, count.index)}"
    Source = "${var.infra_source}"

  }
}

resource "aws_subnet" "private" {
  vpc_id = "${var.vpc_id_mod}"
  count = "${length(var.private_subnets)}"
  cidr_block = "${element(var.private_subnets, count.index)}"
  availability_zone = "${element(var.azs, count.index)}"

  tags = {
    Name = "${element(var.private_subnets_name, count.index)}"
    Source = "${var.infra_source}"
  }
}

resource "aws_internet_gateway" "igw" {
  count = "${length(var.igw_name)}"
  vpc_id = "${var.vpc_id_mod}"

  tags = {
    Name = "${element(var.igw_name, count.index)}"
    Source = "${var.infra_source}"
  }
}

resource "aws_route_table" "public" {
  count = length(var.public_subnets) > 0 ? 1 : 0
  vpc_id = "${var.vpc_id_mod}"
  tags = {
    Name = "${var.pub_rtb_1_name}"
    Source = "${var.infra_source}"
  }
}

resource "aws_route" "pub_igw" {
  route_table_id   = "${aws_route_table.public[0].id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id  = "${aws_internet_gateway.igw[0].id}"

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "pub_igw_ipv6" {
  route_table_id   = "${aws_route_table.public[0].id}"
  destination_ipv6_cidr_block = "::/0"
  gateway_id  = "${aws_internet_gateway.igw[0].id}"

  timeouts {
    create = "5m"
  }
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets) > 0 ? length(var.public_subnets) : 0

  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public[0].id
}

resource "aws_eip" "eip" {
  vpc = true
  tags = {
    Name = "${var.eip_name}"
    Source = "${var.infra_source}"
  }
}

resource "aws_nat_gateway" "nat" {
  count = var.enable_nat_gateway ? 1 : 0
  allocation_id = "${aws_eip.eip.id}"
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  
  depends_on = [aws_internet_gateway.igw]
  tags = {
    Name = "${var.nat_name}"
    Source = "${var.infra_source}"
  }
}

resource "aws_route_table" "private" {
  count = length(var.private_subnets) > 0 ? 1 : 0
  vpc_id = "${var.vpc_id_mod}"
  tags = {
    Name = "${var.pri_rtb_1_name}"
    Source = "${var.infra_source}"
  }
}

resource "aws_route" "private_nat" {
  count = var.enable_nat_gateway ? 1 : 0
  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id  = element(aws_nat_gateway.nat.*.id, count.index)
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnets) > 0 ? length(var.private_subnets) : 0
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private[0].id
}