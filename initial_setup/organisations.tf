resource "aws_organizations_organization" "organization" {
}

resource "aws_organizations_account" "production" {
  name  = "hvoelksen-aws-production"
  email = "hvoelksen+aws-prod@gmail.com"
  #this auto created: role_name = "OrganizationAccountAccessRole"
}


resource "aws_organizations_account" "development" {
  name  = "hvoelksen-aws-development"
  email = "hvoelksen+aws-dev@gmail.com"
}

