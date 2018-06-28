variable "access_key" {}

variable "secret_key" {}

variable "region" {
  default = "us-west-2"
}

variable "profilename" {
  default = "jobbatical"
}

variable "deployer_key_file" {}

variable "deployer_pvt_key_file" {}

variable "jenkins_ami" {
  default = "ami-079e8ddfcebb081ae"
}

variable "account_owner" {
  default = "596766729292"
}

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}
