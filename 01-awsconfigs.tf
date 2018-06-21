variable "access_key" {
  default = "AKIAJH3R7GFTC3LZVPWQ"
}

variable "secret_key" {
  default = "6riC39xIjsz4ZK7mMxpHMX0aInCmUQYL8hWcZnhc"
}

variable "region" {
  default = "us-east-1"
}

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}
