#
#resource "aws_vpc" "us-east-1_vpc" {
#  cidr_block           = "10.10.0.0/16"
#  enable_dns_hostnames = true
#  enable_dns_support   = true
#
#  tags = {
#    Name = "us-east-1_vpc"
#  }
#}

data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

##setup github OIDC idp
#resource "aws_iam_openid_connect_provider" "github" {
#  url             = "https://token.actions.githubusercontent.com"
#  client_id_list  = ["sts.amazonaws.com"]
#  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
#}


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
