


output "plotly_dash_url" {
  value = "http://${aws_elb.dash.dns_name}"
}

output "elb_dns_name" {
  value = "${aws_elb.dash.dns_name}"
}
