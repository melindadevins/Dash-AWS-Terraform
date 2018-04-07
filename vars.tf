variable "server_port" {
  description = "The port the EC2 web server will use for HTTP requests"
  default = 8050
}

variable "primary_region" {
  description = "The primary region of the cluster"
  default = "us-east-1"
}

variable "profile" {
  description = "The AWS profile used to deploy Dash"
  default = "default"
}

variable "service_name" {
  description = "The service name"
  default = "dashproxy"
}


variable "ec2_instance_type" {
  description = "EC2 Instance Type"
  default = "t2.small"
}

variable "num_nodes" {
  description = "Number of nodes in the autoscaling group"
  default = "1"
}

variable "max_num_nodes" {
  description = "Max number of nodes in the autoscaling group"
  default = "2"
}

variable "min_num_nodes" {
  description = "Min of nodes in the autoscaling group"
  default = "1"
}

variable "cis_ami_id" {
  description = "EC2 Image Id"
  default = "ami-1853ac65"  #"ami-69b4ed13"
}

variable "config_bucket_name_prefix" {
  description = "S3 bucket name (config, backups, automation)"
  default = "em-dashproxy-config"
}

variable "environment" {
  description = "The environment identifier e.g. engineering,prod,green,blue"
  default ="test"
}

variable "environment_type" {
  description = "The environment TYPE"
  default = "dev"
}


variable "s3object_key" {
  description = "The key of s3 object that holds resources for Dash deployment"
  default = "dash_resources.zip"
}
variable "resource_dir" {
  description = "Dash resource directory"
  default = "dash_resources"
}
variable "app_path" {
  description = "App path on EC2 instance"
  default = "/opt/dashproxy"
}

variable "ec2_keypair_name" {
  description = "SSH Keypair Name"
  default = "mel-ds-dev-east"
}

variable "dash_proxy_role_prefix"
{
  description = "Dash Proxy Role Name"
  default = "dash_proxy_role"
}
