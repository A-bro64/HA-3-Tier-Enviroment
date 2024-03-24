variable "vpc_cidr" {
  description = "CIDR for VPC"
  type        = string
  default = "10.0.0.0/16"
}

variable "public_subnet_1_cidr" {
  description = "CIDR for Public Subnet 1"
  type        = string
  default = "10.0.10.0/24"
}

variable "public_subnet_1_availability_zone" {
  description = "Public Subnet 1 availability Zone"
  type        = string
  default = "us-west-1a"
}

variable "public_subnet_2_cidr" {
  description = "CIDR for Public Subnet 2"
  type        = string
  default = "10.0.20.0/24"
}

variable "public_subnet_2_availability_zone" {
  description = "Public Subnet 2 availability Zone"
  type        = string
  default = "us-west-1b"

}

variable "private_subnet_1_cidr" {
  description = "CIDR for Private Subnet 1"
  type        = string
  default = "10.0.30.0/24"
}

variable "private_subnet_1_availability_zone" {
  description = "Private Subnet 1 availability Zone"
  type        = string
  default = "us-west-1a"
}

variable "private_subnet_2_cidr" {
  description = "CIDR for private Subnet 2"
  type        = string
  default = "10.0.40.0/24"
}

variable "private_subnet_2_availability_zone" {
  description = "Private Subnet 2 availability Zone"
  type        = string
  default = "us-west-1b"
}

variable "private_subnet_3_cidr" {
  description = "CIDR for private Subnet 3"
  type        = string
  default = "10.0.50.0/24"
}

variable "private_subnet_3_availability_zone" {
  description = "Private Subnet 3 availability Zone"
  type        = string
  default = "us-west-1a"
}

variable "private_subnet_4_cidr" {
  description = "CIDR for private Subnet 4"
  type        = string
  default = "10.0.60.0/24"
}

variable "private_subnet_4_availability_zone" {
  description = "Private Subnet 4 availability Zone"
  type        = string
  default = "us-west-1b"
}

variable "DB_subnet_1_cidr" {
  description = "CIDR for DB Subnet 1"
  type        = string
  default = "10.0.70.0/24"
}

variable "DB_subnet_1_availability_zone" {
  description = "DB Subnet 1 availability Zone"
  type        = string
  default = "us-west-1a"
}

variable "DB_subnet_2_cidr" {
  description = "CIDR for DB Subnet 2"
  type        = string
  default = "10.0.80.0/24"
}

variable "DB_subnet_2_availability_zone" {
  description = "DB Subnet 2 availability Zone"
  type        = string
  default = "us-west-1b"
}

variable "instance_type" {
  description = "Instance type"
  type        = string
  default = "t2.micro"
}

variable "instance_image_id" {
  description = "instance image id"
  type        = string
  default = "ami-0e65ed16c9bf1abc7"
}

variable "instance_private_key" {
  description = "Instance private key"
  type        = string
  default = "+"
}

variable "asg_min" {
  description = "Min numbers of servers in ASG"
  type     = string
  default = "0"
}

variable "asg_max" {
  description = "Max numbers of servers in ASG"
  type     = string
  default = "1"
}

variable "asg_desired" {
  description = "Desired numbers of servers in ASG"
  type     = string
  default = "1"
}

variable "alarm-notification" {
  description = "Phone number to send http-400-error sms notofocation"
  type     = string
  default = "+"
}

variable "zone_id" {
  description = "zone id for r53"
  type = string 
  default = "+"
}

variable "route53_dns" {
  description = "dns name for route 53"
  type = string
  default = "yourdomain-name"
}
