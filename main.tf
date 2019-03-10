# define terraform version
terraform {
  required_version = ">= 0.11.8"
}

# define aws provider version and region
provider "aws" {
  version = ">= 1.47.0"
  region  = "${var.region}"
}

provider "random" {
  version = "= 1.3.1"
}

# get all availability zones
data "aws_availability_zones" "available" {}