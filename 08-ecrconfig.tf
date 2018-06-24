resource "aws_ecr_repository" "jobbatical-ecr" {
  name = "jobbatical-ecr"
}

output "jobbatical-ecr-arn" {
  value = "${aws_ecr_repository.jobbatical-ecr.arn}"
}

output "jobbatical-ecr-url" {
  value = "${aws_ecr_repository.jobbatical-ecr.repository_url}"
}
