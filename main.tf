#Specify the provider and access details
provider "aws" {
  region = "${var.primary_region}"
}



resource "aws_security_group" "instance" {
  name = "dash-instance"
  ingress {
    from_port = "${var.server_port}"
    to_port = "${var.server_port}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "dash" {
  image_id = "ami-40d28157"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.instance.id}"]
  user_data = <<-EOF
          #!/bin/bash
          echo "Hello, Melinda" > index.html
          nohup busybox httpd -f -p 8080 &
          EOF
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "dash" {
  launch_configuration = "${aws_launch_configuration.dash.id}"
  availability_zones = ["${data.aws_availability_zones.all.names}"]

  load_balancers = ["${aws_elb.dash.name}"]
  health_check_type = "ELB"

  min_size = 1
  max_size = 2
  tag {
    key = "Name"
    value = "terraform-asg-dash"
    propagate_at_launch = true
  }
}


resource "aws_elb" "dash" {
  name = "terraform-asg-dash"
  availability_zones = ["${data.aws_availability_zones.all.names}"]
  security_groups = ["${aws_security_group.elb.id}"]

  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = "${var.server_port}"
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 120
    target = "HTTP:${var.server_port}/"
  }
}

resource "aws_security_group" "elb" {
  name = "terraform-dash-elb"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp" cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}