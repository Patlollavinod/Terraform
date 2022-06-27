#  provider "aws" {
#       region = "ap-south-1"
#  }
resource "aws_instance" "app" {
    instance_type       = "t2.micro"
    ami                 = "ami-068257025f72f470d"
    availability_zone   = "ap-south-1"
}
resource "aws_lb_target_group" "my_target_group" {
    health_check {
        interval =              10
        path =                  "/index.html"
        protocol =              "HTTP"
        timeout =               5
        healthy_threshold =     5
        unhealthy_threshold =   2
    }
    name     = "tf-test-lb-tg"
    port     = 80
    protocol = "HTTP"
    vpc_id   = var.vpc_id
}

resource  "aws_lb" "my-aws-alb" {
  name =            "my-test-alb"
  internal =        false
  security_groups = var.vpc_security_group
  subnets =        ["subnet-0bee8832e401ccc6b","subnet-04db015a12e1a2d09"]
}

resource "aws_lb_listener" "aws_lb_listener_test" {
  load_balancer_arn = aws_lb.my-aws-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_target_group.arn
}
}
resource "aws_launch_configuration" "vin-conf" {
  name_prefix   = "vin-lc"
  image_id      = var.ubantu-ami
  instance_type = "t2.micro"
  security_groups = var.vpc_security_group
  associate_public_ip_address = true
   user_data = <<-EOF
                #!/bin/bash
                apt-get update -y
                apt-get install nginx -y
                systemctl start nginx
                systemctl enable nginx
                mkdir /var/www/html
                echo "This is from launch configuration-2" > /var/www/html/index.html
                EOF
 lifecycle {
    create_before_destroy = true
  }
}
data "aws_subnets" "example" { 
 filter{    
  name = "vpc-id"    
  values = [var.vpc_id]  
 }
}
resource "aws_autoscaling_group" "vin-asg" {
  name                 = "vin-lc"
  min_size             = 1
  desired_capacity     = 1
  max_size             = 2
  health_check_type    = "EC2"
  launch_configuration = "${aws_launch_configuration.vin-conf.id}"
  vpc_zone_identifier = "${data.aws_subnets.example.ids}"
  target_group_arns = [ "${aws_lb_target_group.my_target_group.arn}" ]
  lifecycle {
    create_before_destroy = true
  }
}
