
output "path_module" {
  value = "${path.module}"
}


output "path_root" {
  value = "${path.root}"
}

output "elb_dns_name" {
  value = "${aws_elb.dash.dns_name}"
}
