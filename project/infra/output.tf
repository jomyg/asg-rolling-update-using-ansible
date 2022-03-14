data "aws_instances" "asg" {
  filter {
    name   = "tag:Name"
    values = ["${var.project_name}" ]
  }
  instance_state_names = ["running"]
}


output "instances" {
    
  value = data.aws_instances.asg.public_ips
}
