#data "aws_caller_identity" "current" {}
#
#output "account_id" {
#  value = data.aws_caller_identity.current.account_id
#}

resource "aws_iam_account_alias" "alias" {
  account_alias = "hv-aws-management"
}

#create admin user group and user
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

resource "aws_iam_user_group_membership" "user-group" {
  user = aws_iam_user.user1.name

  groups = [
    aws_iam_group.Administrators.name,
  ]
}

#enforce mfa for admin user group 
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

##example for secondary policy attachment using aws managed policy ie not a tf name
#resource "aws_iam_group_policy_attachment" "policy-attach2" {
#  group      = aws_iam_group.Administrators.name
#  policy_arn = "arn:aws:iam::aws:policy/IAMUserChangePassword"
#}

###user mfa
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


#setup github OIDC idp
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}


#github role trust
data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:htr2/aws_*:*", #!! limit the trust of who can call the role to our repo(s)!!! otherwise open to all of github!!!
        #"repo:org2/*:*"
      ]
    }
  }
}


resource "aws_iam_role" "github_actions" {
  name               = "github-actions"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json
}

#github role permission
data "aws_iam_policy_document" "github_actions" {
  statement {
    actions = ["sts:AssumeRole"]
    resources = ["arn:aws:iam::${aws_organizations_account.production.account_id}:role/OrganizationAccountAccessRole"]
  }
}

resource "aws_iam_policy" "github_actions" {
  name        = "github-actions"
  description = "Grant Github Actions the ability assume role in prod account"
  policy      = data.aws_iam_policy_document.github_actions.json
}


#role 
resource "aws_iam_role_policy_attachment" "github_actions" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions.arn
}
