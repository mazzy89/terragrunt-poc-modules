variable "aws_region" {
  description = "The AWS region to deploy to (e.g. us-east-1)"
}

variable "environment" {
  description = "The name of the environment (e.g. dev)"
}

variable "environment_type" {
  description = "A tag to distinguish across same environments which environment is (e.g. blue)"
}
