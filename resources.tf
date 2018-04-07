resource "random_id" "suffix" {
  byte_length = 8
}

#create s3 bucket for Dash configuration reesources
resource "aws_s3_bucket" "resouce_bucket" {
  region = "${var.primary_region}"
  bucket = "${var.config_bucket_name_prefix}-${var.environment}"
  acl = "private"
}


resource "local_file" "deploy_vars" {
  depends_on = [ "aws_s3_bucket.resouce_bucket" ]
  content = <<EOF
service_name=${var.service_name}
ec2_instance_type=${var.ec2_instance_type}
num_nodes=${var.num_nodes}
cis_ami_id=${var.cis_ami_id}
ec2_keypair_name=${var.ec2_keypair_name}
environment=${var.environment}
environment_type=${var.environment_type}
primary_region=${var.primary_region}
server_port=${var.server_port}

config_bucket_name=${var.config_bucket_name_prefix}-${var.environment}
s3object_key=${var.s3object_key}
resource_dir=${var.resource_dir}
app_path=${var.app_path}
server_port=${var.server_port}
EOF
  filename = "${path.root}/${var.resource_dir}/vars.tfvars"
}


data "archive_file" "resource_zip" {
depends_on = [ "local_file.deploy_vars" ]
type = "zip"
source_dir = "${path.root}/${var.resource_dir}"
output_path = "${path.root}/${var.resource_dir}.zip"
}

resource "aws_s3_bucket_object" "resource_object" {
depends_on = [ "data.archive_file.resource_zip" ]
key = "${var.s3object_key}"
bucket = "${aws_s3_bucket.resouce_bucket.bucket}"
source = "${path.root}/${var.resource_dir}.zip"
etag   = "${data.archive_file.resource_zip.output_md5}"
}
