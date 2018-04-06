variable "server_port" {
  description = "The port the EC2 web server will use for HTTP requests"
  default = 8080
}

variable "primary_region" {
  description = "The primary region of the cluster"
  default = "us-east-1"
}