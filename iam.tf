resource "aws_iam_group" "billingadmins" {
  name = "billingadmins"
  #path = "/users/"
}

#not defining own policy but use aws managed one
#resource "aws_iam_policy" "policy" {
#  name        = "test-policy"
#  description = "A test policy"
#  policy      = "{ ... policy JSON ... }"
#}

resource "aws_iam_group_policy_attachment" "policy-attach1" {
  group      = aws_iam_group.billingadmins.name
  policy_arn = "arn:aws:iam::aws:policy/job-function/Billing"
}

resource "aws_iam_group_policy_attachment" "policy-attach2" {
  group      = aws_iam_group.billingadmins.name
  policy_arn = "arn:aws:iam::aws:policy/IAMUserChangePassword"
}


resource "aws_iam_user" "billinguser" {
  name = "billinguser"
  #path = "/system/"
}

resource "aws_iam_user_login_profile" "user-login-profile" {
  user    = aws_iam_user.billinguser.name
}
output "password" {
  value = aws_iam_user_login_profile.user-login-profile.password
}


resource "aws_iam_user_group_membership" "user-group" {
  user = aws_iam_user.billinguser.name

  groups = [
    aws_iam_group.billingadmins.name,
  ]
}