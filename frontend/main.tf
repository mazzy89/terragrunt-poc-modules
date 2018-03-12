provider "aws" {
  region = "${var.aws_region}"
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

locals {
  frontend = "${var.environment}-${var.environment_type}-frontend"
}

##################################################################
# Data sources to get VPC, subnet, security group and AMI details
##################################################################
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = "${data.aws_vpc.default.id}"
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "amzn-ami-hvm-*-x86_64-gp2",
    ]
  }

  filter {
    name = "owner-alias"

    values = [
      "amazon",
    ]
  }
}

data "terraform_remote_state" "iam" {
  backend = "s3"

  config {
    bucket = "${var.iam_remote_tfstate_bucket}"
    key    = "${var.iam_remote_tfstate_key}"
    region = "${var.aws_region}"
  }
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "1.9.0"

  name                = "${local.frontend}"
  description         = "Security group for example usage with EC2 instance"
  vpc_id              = "${data.aws_vpc.default.id}"
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "all-icmp"]
  egress_rules        = ["all-all"]
}

resource "aws_eip" "this" {
  vpc      = true
  instance = "${module.ec2.id[0]}"
}

module "ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "1.3.0"

  name                        = "${local.frontend}"
  ami                         = "${data.aws_ami.amazon_linux.id}"
  instance_type               = "t2.micro"
  subnet_id                   = "${element(data.aws_subnet_ids.all.ids, 0)}"
  vpc_security_group_ids      = ["${module.security_group.this_security_group_id}"]
  associate_public_ip_address = true
  iam_instance_profile        = "${data.terraform_remote_state.iam.instance_profile}"
}
