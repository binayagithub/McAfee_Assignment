resource "aws_instance" "ec2" {
  ami           = "${var.instance_ami}"
  instance_type = "${var.instance_type}"
  key_name = "${var.key_name}"
  subnet_id = "${var.public_subnet_id_1_mod}"

  vpc_security_group_ids       = [ ]

  tags = {
    Name = "${var.instance_name}"
    Source = "${var.infra_source}"
  }
}