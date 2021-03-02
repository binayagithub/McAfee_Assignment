
resource "aws_security_group" "emr_master_private" {
  vpc_id     = "${var.vpc_id_mod}"
  name = "${var.emr_security_group_master_private_name}"
  
  tags = {
    Name = "${var.emr_security_group_master_private_name}"
    Source = "${var.infra_source}"
  }
}

resource "aws_security_group" "emr_slave_private" {
  vpc_id     = "${var.vpc_id_mod}"
  name = "${var.emr_security_group_slave_private_name}"
  
  tags = {
    Name = "${var.emr_security_group_slave_private_name}"
    Source = "${var.infra_source}"
  }
}


resource "aws_security_group_rule" "emr_master_private_tcp_self" {
  type = "ingress"
  from_port   = 0
  to_port     = 65535
  protocol    = "tcp"
  self = true
  security_group_id = aws_security_group.emr_master_private.id
}

resource "aws_security_group_rule" "emr_master_private_udp_self" {
  type = "ingress"
  from_port   = 0
  to_port     = 65535
  protocol    = "udp"
  self = true
  security_group_id = aws_security_group.emr_master_private.id
}

resource "aws_security_group_rule" "emr_master_private_icmp_self" {
  type = "ingress"
  from_port   = -1
  to_port     = -1
  protocol    = "icmp"
  self = true
  security_group_id = aws_security_group.emr_master_private.id
}

resource "aws_security_group_rule" "emr_master_private_tcp" {
  type = "ingress"
  from_port   = 0
  to_port     = 65535
  protocol    = "tcp"
  security_group_id = aws_security_group.emr_master_private.id
  source_security_group_id = "${aws_security_group.emr_slave_private.id}"
}

resource "aws_security_group_rule" "emr_master_private_udp" {
  type = "ingress"
  from_port   = 0
  to_port     = 65535
  protocol    = "udp"
  security_group_id = aws_security_group.emr_master_private.id
  source_security_group_id = "${aws_security_group.emr_slave_private.id}"
}

resource "aws_security_group_rule" "emr_master_private_icmp" {
  type = "ingress"
  from_port   = -1
  to_port     = -1
  protocol    = "icmp"
  security_group_id = aws_security_group.emr_master_private.id
  source_security_group_id = "${aws_security_group.emr_slave_private.id}"
}



















resource "aws_security_group_rule" "emr_slave_private_tcp_self" {
  type = "ingress"
  from_port   = 0
  to_port     = 65535
  protocol    = "tcp"
  self = true
  security_group_id = aws_security_group.emr_slave_private.id
}

resource "aws_security_group_rule" "emr_slave_private_udp_self" {
  type = "ingress"
  from_port   = 0
  to_port     = 65535
  protocol    = "udp"
  self = true
  security_group_id = aws_security_group.emr_slave_private.id
}

resource "aws_security_group_rule" "emr_slave_private_icmp_self" {
  type = "ingress"
  from_port   = -1
  to_port     = -1
  protocol    = "icmp"
  self = true
  security_group_id = aws_security_group.emr_slave_private.id
}

resource "aws_security_group_rule" "emr_slaveprivate_tcp" {
  type = "ingress"
  from_port   = 0
  to_port     = 65535
  protocol    = "tcp"
  security_group_id = aws_security_group.emr_slave_private.id
  source_security_group_id = "${aws_security_group.emr_master_private.id}"
}

resource "aws_security_group_rule" "emr_slave_private_udp" {
  type = "ingress"
  from_port   = 0
  to_port     = 65535
  protocol    = "udp"
  security_group_id = aws_security_group.emr_slave_private.id
  source_security_group_id = "${aws_security_group.emr_master_private.id}"
}

resource "aws_security_group_rule" "emr_slave_private_icmp" {
  type = "ingress"
  from_port   = -1
  to_port     = -1
  protocol    = "icmp"
  security_group_id = aws_security_group.emr_slave_private.id
  source_security_group_id = "${aws_security_group.emr_master_private.id}"
}