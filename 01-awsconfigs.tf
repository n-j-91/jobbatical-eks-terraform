/*variable "access_key" {}

variable "secret_key" {}
*/
variable "access_key" {
  default = "AKIAJO6P5B6XMVYJ2IXA"
}

variable "secret_key" {
  default = "nTlAcCjKgtNq819EZ2xVdMs9sJwkG3+C+5VJ/fXm"
}

variable "region" {
  default = "us-east-1"
}

variable "profilename" {
  default = "jobbatical"
}

variable "deployer_key_file" {}

variable "deployer_pvt_key_file" {}

variable "jenkins_ami" {
  default = "ami-0b1e3825d1162ae43"
}

variable "account_owner" {
  default = "596766729292"
}

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}
