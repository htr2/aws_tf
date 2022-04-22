resource "aws_iam_account_alias" "alias" {
  account_alias = "hv-aws-management"
}

resource "aws_iam_user" "user1" {
  name = "Administrator"
  #path = "/system/"
}

resource "aws_iam_user_login_profile" "user1-login-profile" {
  user    = aws_iam_user.user1.name
}

output "password" {
  value = aws_iam_user_login_profile.user1-login-profile.password #!!!cleartext password!!! 
}

resource "aws_iam_access_key" "user1-key" {
  user = aws_iam_user.user1.name
}

output "key" {
  value = aws_iam_access_key.user1-key.id
}

output "secret" {
  value = aws_iam_access_key.user1-key.secret
}


resource "aws_iam_group" "Administrators" {
  name = "Administrators"
  #path = "/users/"
}


resource "aws_iam_policy" "AdministratorAccess-MFAenforced" {
  name        = "AdministratorAccess-MFAenforced"
  description = "requires MFA..."
  policy      = jsonencode({
                              "Version": "2012-10-17",
                              "Statement": [
                                  {
                                      "Effect": "Allow",
                                      "Action": "*",
                                      "Resource": "*",
                                      "Condition": {
                                          "Bool": {
                                              "aws:MultiFactorAuthPresent": "true"
                                          }
                                      }
                                  }
                              ]
                          })
}

resource "aws_iam_group_policy_attachment" "policy-attach1" {
  group      = aws_iam_group.Administrators.name
  policy_arn = aws_iam_policy.AdministratorAccess-MFAenforced.id
}

#resource "aws_iam_group_policy_attachment" "policy-attach2" {
#  group      = aws_iam_group.billingadmins.name
#  policy_arn = "arn:aws:iam::aws:policy/IAMUserChangePassword"
#}

resource "aws_iam_user_group_membership" "user-group" {
  user = aws_iam_user.user1.name

  groups = [
    aws_iam_group.Administrators.name,
  ]
}


###mfa
#left out as one cannot complete activate mfa device (authenticator app) by code....requires QRcode scanning by app or code entry...
#so if manual required do all manual...
#also aws provider has bug and mangles qr code output unusable, aws cli works..., string seed might work too...
/*
resource "aws_iam_virtual_mfa_device" "testing_mfa_qr" {
  virtual_mfa_device_name = "qr_png_test"
}

output "mfa_arn" {
  value     = aws_iam_virtual_mfa_device.testing_mfa_qr.arn
}

output "mfa_seed" { #base64-encoded
  value     = aws_iam_virtual_mfa_device.testing_mfa_qr.base_32_string_seed
}

resource "local_file" "private_key" {
    content  = aws_iam_virtual_mfa_device.testing_mfa_qr.qr_code_png
    filename = "mfa_qr.png"
}

output "mfa_qr" {
  #sensitive = true
  value     = aws_iam_virtual_mfa_device.testing_mfa_qr.qr_code_png
}
*/