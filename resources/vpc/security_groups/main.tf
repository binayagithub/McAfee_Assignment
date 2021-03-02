resource "aws_security_group" "security_group_public" {
  vpc_id     = "${var.vpc_id_mod}"
  name = "${var.security_group_public_name}"
  
  tags = {
    Name = "${var.security_group_public_name}"
    Source = "${var.infra_source}"
  }
}

resource "aws_security_group" "security_group_private" {
  vpc_id     = "${var.vpc_id_mod}"
  name = "${var.security_group_private_name}"
  
  tags = {
    Name = "${var.security_group_private_name}"
    Source = "${var.infra_source}"
  }
}