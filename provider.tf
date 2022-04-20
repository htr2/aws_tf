terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"

    }
  }
}

# Configure the AWS Provider
# although with a few cruxes (e.g. alias provider passed to modules, or scripts to generate providers etc) it is possible to define multi region deployments,
# considered complicated and impacting large blast ranges... lets stick to simple things....

provider "aws" {
  region = "us-east-1"
}