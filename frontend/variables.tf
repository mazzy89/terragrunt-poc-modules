variable "aws_region" {
  description = "The AWS region to deploy to (e.g. us-east-1)"
}

variable "environment" {
  description = "The name of the environment (e.g. dev)"
}

variable "environment_type" {
  description = "A tag to distinguish across same environments which environment is (e.g. blue)"
}

variable "iam_tfstate_bucket" {
  description = "The name of the S3 bucket for the IAM's remote state"
}

variable "iam_tfstate_key" {
  description = "The path for the IAM's remote state in S3"
}
