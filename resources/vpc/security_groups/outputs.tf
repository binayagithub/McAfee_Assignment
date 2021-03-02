output "security_group_public_id" {
    value = "${aws_security_group.security_group_public.id}"
}
output "security_group_private_id" {
    value = "${aws_security_group.security_group_private.id}"
}