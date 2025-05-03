resource "aws_lb" "external-alb" {
  name               = "external-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_securityGP.id]
  subnets            = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]

}

resource "aws_lb_target_group" "alb-targetgroup" {
  vpc_id      = aws_vpc.ranjitvpc.id
  name        = "alb-target"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  health_check {
    path                = "/index.html"
    port                = 80
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-299"

  }

}

resource "aws_lb_target_group_attachment" "alb-TGattachment" {
  target_group_arn = aws_lb_target_group.alb-targetgroup.arn
  target_id        = aws_instance.ec2_ins.id
  port             = 80
  depends_on = [
    aws_lb_target_group.alb-targetgroup,
    aws_instance.ec2_ins

  ]
}

resource "aws_lb_listener" "name" {
  load_balancer_arn = aws_lb.external-alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-targetgroup.arn
  }
}


resource "aws_launch_template" "EC2launch" {
  instance_type = "t2.micro"
  #availability_zone      = var.availabilityzone[count.index]
  image_id = "ami-002f6e91abff6eb96"
  user_data = base64encode(<<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y httpd
    sudo systemctl start httpd
    sudo systemctl enable httpd
    echo "Hello from Auto Scaling Group instance" > /var/www/html/index.html
  EOF
  )
  network_interfaces {
    security_groups = [aws_security_group.alb_securityGP.id]
    subnet_id       = aws_subnet.private_subnet.id

  }

}

resource "aws_autoscaling_group" "AS-group" {
  vpc_zone_identifier       = [aws_subnet.private_subnet.id]
  desired_capacity          = 1
  max_size                  = 2
  min_size                  = 1
  health_check_type         = "ELB"
  health_check_grace_period = "60"
  launch_template {
    id      = aws_launch_template.EC2launch.id
    version = "$Latest"
  }
  target_group_arns = [aws_lb_target_group.alb-targetgroup.arn]

  tag {

    key                 = "Name"
    value               = "ASG-Instance"
    propagate_at_launch = true
  }
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_autoscaling_policy" "ASpolicy" {
  autoscaling_group_name = aws_autoscaling_group.AS-group.name
  name                   = "scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
}

resource "aws_cloudwatch_metric_alarm" "high-cpu" {
  alarm_name          = "high-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 50
  alarm_description   = "cpu utilization is more than 30"
  alarm_actions = [
    aws_autoscaling_policy.ASpolicy.arn,
    aws_sns_topic.alarm-notifications.arn
  ]
  dimensions = {
    autoscaling_group_name = aws_autoscaling_group.AS-group.name
  }
}

resource "aws_autoscaling_policy" "scale-down" {
  autoscaling_group_name = aws_autoscaling_group.AS-group.name
  name                   = "scale-down"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60

}

resource "aws_cloudwatch_metric_alarm" "low-cpu" {
  alarm_name          = "low-cpu-usage"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 60
  alarm_description   = "Scale down when CPU < 30% for 4 minutes"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.AS-group.name
  }
  alarm_actions = [
    aws_autoscaling_policy.scale-down.arn,
    aws_sns_topic.alarm-notifications.arn
  ]
}


# SNS topic for email notifications

resource "aws_sns_topic" "alarm-notifications" {
  name = "alarm-notification-topic"

}

resource "aws_sns_topic_subscription" "name" {
  topic_arn = aws_sns_topic.alarm-notifications.arn
  protocol  = "email"
  endpoint  = "nagi.harjinder@gmail.com"

}