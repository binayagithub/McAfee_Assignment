resource "aws_iam_policy" "iam_policy" {
  name        = "${var.policy_name}"
  path        = "/"
  
  policy = "${var.policy}"
}