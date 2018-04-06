# Use this to get the AWS Account Id
# ${data.aws_caller_identity.current.account_id}
data "aws_caller_identity" "current" {}

/*
output "account_id" {
  value = "${data.aws_caller_identity.current.account_id}"
}

output "caller_arn" {
  value = "${data.aws_caller_identity.current.arn}"
}

output "caller_user" {
  value = "${data.aws_caller_identity.current.user_id}"
}
*/

# "${data.aws_region.current.name}"
data "aws_region" "current" {
  current = true
}

# Query elmae VPC

# Get our elmae-default vpc
data "aws_vpc" "elmae" {
  tags {
    Name = "elmae-default"
  }
}

# private subnets
data "aws_subnet" "private_subnet_0" {
  vpc_id = "${data.aws_vpc.elmae.id}"
  filter {
    name="tag:Name"
    values=["Private0*"]
  }
}

data "aws_subnet" "private_subnet_1" {
  vpc_id = "${data.aws_vpc.elmae.id}"
  filter {
    name="tag:Name"
    values=["Private1*"]
  }
}

data "aws_subnet" "private_subnet_2" {
  vpc_id = "${data.aws_vpc.elmae.id}"
  filter {
    name="tag:Name"
    values=["Private2*"]
  }
}

# public subnets
data "aws_subnet" "public_subnet_0" {
  vpc_id = "${data.aws_vpc.elmae.id}"
  filter {
    name="tag:Name"
    values=["Public0*"]
  }
}

data "aws_subnet" "public_subnet_1" {
  vpc_id = "${data.aws_vpc.elmae.id}"
  filter {
    name="tag:Name"
    values=["Public1*"]
  }
}

data "aws_subnet" "public_subnet_2" {
  vpc_id = "${data.aws_vpc.elmae.id}"
  filter {
    name="tag:Name"
    values=["Public2*"]
  }
}

data "aws_availability_zones" "all" {}

# Template for initial configuration bash script
#user_data = "${data.template_file.init.rendered}"

/*
data "template_file" "init" {
  template = "${file("${path.module}/init.tpl")}"

  vars {

    environment = "${var.environment}"
    config_bucket_name = "${var.config_bucket_name_prefix}-${var.environment}"
    s3object_key = "${var.s3object_key}"
    resource_dir = "${var.resource_dir}"
    app_path = "${var.app_path}"
    region = "${data.aws_region.current.name}"
    resources_zip_md5 = "${data.archive_file.resource_zip.output_md5}"
    route53_zone_base = "${var.route53_zone_base}"
  }
}


data "aws_route53_zone" "hosted_zone" {
  name         = "${var.route53_zone_base}."
  private_zone = "${var.is_hosted_zone_private}"
  provider = "aws"
}
*/