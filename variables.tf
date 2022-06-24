variable "region" {
    type    = string
    default = "ap-south-1"
}

variable "network_cidr" {
    type    = string
    default = "10.0.0.0/16"

}

variable "subnet_name_tags" {
    type    = list(string)
    default = [ "Public-1", "Public-1", "private-1", "private-2",  ]

}

variable "bucket_name" {
    type    = string
    default = "patlolla_sample"

} 
variable "aws_region" {
    default = "ap-south-1"
}
variable "ubantu-ami" {
    default = "ami-0756a1c858554433e"
}
variable "instance_type" {
    default = "t2.micro"
}
variable "ec2_count" {
    type = number
    default = "4"
}
variable "vpc_security_group" {
    default = ["sg-07243c3762e88e437"]
}
variable "environment" {
    default ="dev"
}
variable "product" {
    default = "server"
}
variable "subnets" {
    type = list
    default = ["subnet-0bee8832e401ccc6b","subnet-04db015a12e1a2d09"]
}

variable "vpc_id" {
    default = "vpc-05fdf739745f2db7f"
}
variable "server_port" {
    default = "80"
}
  
