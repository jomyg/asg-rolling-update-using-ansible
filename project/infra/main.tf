
# ======================================================
# KeyPair For The Project
# ======================================================

resource "aws_key_pair"  "key" {
    
  key_name = "${var.project_name}"
  public_key = file("../authentication/terraform.pub")
  tags = {
    Name = var.project_name
    project = var.project_name
    environment = var.project_env
  }
}



# ======================================================
# Security Group For Project
# ======================================================

resource "aws_security_group" "freedom" {
    
  name        = "${var.project_name}-freedom"
  description = "allow 22 traffic"
  
  ingress {
    description      = ""
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks = [ "::/0" ]
  }
    
  ingress {
    description      = ""
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks = [ "::/0" ]
  }
    
  
    
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.project_name}-freedom"
    project = var.project_name
     environment = var.project_env
  }
}


# ======================================================
# Classic Loadbalancer
# ======================================================

resource "aws_elb" "clb" {
  
  name_prefix             = "${var.project_name}"
  subnets                 = var.clb_subnets 
  security_groups         = [ aws_security_group.freedom.id ]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }


  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 20
  }


  cross_zone_load_balancing   = true
  idle_timeout                = 60
  connection_draining         = true
  connection_draining_timeout = 10

  tags = {
    Name = "${var.project_name}-freedom"
    project = var.project_name
     environment = var.project_env
  }
}




# ======================================================
# Launch Configuration
# ======================================================

resource "aws_launch_configuration" "lc" {
  name_prefix       = "${var.project_name}-"
  image_id          = var.instance_ami
  instance_type     = var.instance_type
  security_groups   = [ aws_security_group.freedom.id ]
  key_name          =  aws_key_pair.key.id
  lifecycle {
    create_before_destroy = true
  }
}





# ======================================================
# Launch Asg
# ======================================================

resource "aws_autoscaling_group" "asg" {
  
  name_prefix             = "${var.project_name}-"
  launch_configuration    = aws_launch_configuration.lc.id
  health_check_type       = "EC2"
  min_size                = var.asg_count
  max_size                = var.asg_count
  desired_capacity        = var.asg_count
  vpc_zone_identifier     = var.clb_subnets 
  load_balancers          = [ aws_elb.clb.id ]
  tag {
    key = "Name"
    propagate_at_launch = true
    value = "${var.project_name}"
  }

  lifecycle {
    create_before_destroy = true
  }

}
