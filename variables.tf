variable "aws_region"{
    default = "us-east-1"
}

variable "aws_profile"{
    default = "default"
}

variable "vpc_cidr"{
    type = string 
}

variable "everywhere"{
    type = string 
}

variable "CIDRS" {
    type = map 
}
variable "ami" {
    type = string 
}
variable "instance_type" {
    type = string 
}

variable "key_name" {
    type = string 
}

variable "associate_public_ip_address" {
    type = map 
}
variable "user_data" {
    type = string 
}
