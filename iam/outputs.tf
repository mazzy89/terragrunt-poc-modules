output "iam_instance_profile" {
  description = "The name of the instance profile"
  value       = "${aws_iam_instance_profile.this.name}"
}
