variable "ami_name" {
  type    = string
  default = "ami-04ad2567c9e3d7893"

}

variable "type" {
  type    = string
  default = "t2.micro"

}

variable "vpc_cidr" {
  default = "10.20.0.0/16"

}

variable "subnet_cidr" {
  type    = list(any)
  default = ["10.20.1.0/24", "10.20.3.0/24"]

}

variable "azs" {
  type    = list(any)
  default = ["us-east-1a", "us-east-1b"]

}