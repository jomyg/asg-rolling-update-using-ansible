variable "project_name" {
    
  description = "Project name"
  default = "<your project name> "

}

variable "project_env" {
    
  description = "Project Environment"
  default = "prod"  
  
}

variable "instance_ami" {
  
  description = "Instance Ami Id"
  default = "ami-0e0ff68cb8e9a188a"
}

variable "instance_type" {
  
  description = "Instance Type"
  default = "t2.micro"
}


variable "asg_count" {
    
  default = 3
}

variable "clb_subnets" {
    
  default = ["<subnetid>" , "<subnetid>"]
