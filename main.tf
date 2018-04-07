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

  ingress {
    cidr_blocks = ["10.0.0.0/8"]
    from_port = -1
    to_port = -1
    protocol = "icmp"
  }

  ingress {
    #cidr_blocks = ["10.0.0.0/8"]
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 22
    protocol = "tcp"
    to_port = 22
  }

  #verify :may or may not need this
  ingress {
    security_groups = ["${aws_security_group.elb.id}"]
    from_port = 80
    protocol = "tcp"
    to_port = 80
  }

  ingress {
    security_groups = ["${aws_security_group.elb.id}"]
    from_port = 443
    protocol = "tcp"
    to_port = 443
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]

  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "dash" {
  iam_instance_profile = "${aws_iam_instance_profile.DashProxyInstanceProfile.name}"

  image_id = "${var.cis_ami_id}"   #"ami-40d28157"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.instance.id}"]

  key_name = "${var.ec2_keypair_name}"
  user_data = "${data.template_file.init.rendered}"

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
    unhealthy_threshold = 10
    timeout = 3
    interval = 300
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

resource "aws_iam_instance_profile" "DashProxyInstanceProfile" {
  path = "/"
  role = "${aws_iam_role.DashProxyRole.name}"
}

resource "aws_iam_role" "DashProxyRole" {
  name = "${var.dash_proxy_role_prefix}-${random_id.suffix.hex}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
      "Effect": "Allow",
      "Principal": {
          "Service": [
              "ec2.amazonaws.com"
          ]
      },
      "Action": [
          "sts:AssumeRole"
      ]
  }]
}
EOF

  path = "/"
}


resource "aws_iam_policy" "root" {
  #role = "${aws_iam_role.DashProxyRole.id}"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [{
        "Effect": "Allow",
        "Action": [
            "ec2:DescribeInstances",
            "ec2:DescribeTags",
            "cloudformation:DescribeStacks",
            "kms:Decrypt",
            "sts:AssumeRole",
             "iam:GetUser"
        ],
        "Resource": "*"
    }, {
        "Effect": "Allow",
        "Action": [
            "logs:Create*",
            "logs:PutLogEvents",
            "logs:DescribeLogStreams"
        ],
        "Resource": "arn:aws:logs:*:*:*"
    }, {
        "Action": [
            "s3:GetObject",
            "s3:PutObject",
            "s3:DeleteObject"
        ],
        "Effect": "Allow",
        "Resource": [
          "arn:aws:s3:::${var.config_bucket_name_prefix}-${var.environment}/dash_resources.zip",
          "arn:aws:s3:::${var.config_bucket_name_prefix}-${var.environment}/*"
        ]
    }, {
        "Action": [
            "s3:ListBucket"
        ],
        "Effect": "Allow",
        "Resource": [
          "arn:aws:s3:::${var.config_bucket_name_prefix}-${var.environment}"
        ]
    }]
}
EOF
}


resource "aws_iam_role_policy_attachment" "custom_s3_policy_attach" {
  role       = "${aws_iam_role.DashProxyRole.name}"
  policy_arn = "${aws_iam_policy.root.arn}"
}


