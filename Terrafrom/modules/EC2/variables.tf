variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "instance_type" {
  default = "t3.small"
}

variable "key_name" {
  default = "devops-key"
}