variable "ami_id" {
  description = "EC2 instance type"
  type = string
  default = "t2.micro"
}

variable "instance_type" {
  description = "EC2 AMI Id"
  type = string
}

variable "subnet_id" {
  description = "Value for the subnet id"
}