# Use this to get the AWS Account Id
# ${data.aws_caller_identity.current.account_id}
data "aws_caller_identity" "current" {}

data "aws_availability_zones" "all" {}

data "aws_region" "current" {
  current = true
}

# Template for initial configuration bash script
#user_data = "${data.template_file.init.rendered}"
data "template_file" "init" {

  template = "${file("${path.root}/init.tpl")}"

  vars {
    environment = "${var.environment}"
    config_bucket_name = "${var.config_bucket_name_prefix}-${var.environment}"
    s3object_key = "${var.s3object_key}"
    resource_dir = "${var.resource_dir}"
    app_path = "${var.app_path}"
    server_port= "${var.server_port}"
    region = "${data.aws_region.current.name}"
    resources_zip_md5 = "${data.archive_file.resource_zip.output_md5}"
  }
}
