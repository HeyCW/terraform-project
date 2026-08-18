data "aws_ami" "image" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_launch_template" "launch_template" {
  name_prefix   = var.project_name
  image_id      = data.aws_ami.image.id
  instance_type = var.instance_type

  vpc_security_group_ids = [var.sg_id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl enable httpd
    systemctl start httpd

    echo "<h1>Hello from Terraform</h1>" > /var/www/html/index.html
  EOF
  )
}

resource "aws_autoscaling_group" "asg" {
  vpc_zone_identifier = var.subnet_ids
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  min_size            = var.min_size

  target_group_arns = var.target_group_arns
  health_check_type = "ELB"

  launch_template {
    id      = aws_launch_template.launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = var.project_name
    propagate_at_launch = true
  }
}

