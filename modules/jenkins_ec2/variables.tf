variable "env" {
  default = "Production"
}
variable "my_machine_ip" {
  description = "IP address of your machine"
  default     =  "96.127.73.76/32"
  
}

variable "vpc_name" {
  type = string
}

variable "alb_name" {
  type = string
}

variable "key_name" {
  type = string
}

variable "kms_key_id" {
  type = string
}

variable "instance_name" {
  type = string
}

variable "security_group_name_ec2" {
  type = string
}

variable "subnet_ids_alb" {
type = list
}

variable "private_subnet_id" {
type = string
}
