variable "region" {
  type    = string
  default = "ap-southeast-1" # Singapore
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "db_name" {
  type    = string
  default = "wordpress"
}

variable "db_username" {
  type    = string
  default = "wpadmin"
}

variable "db_password" {
  type      = string
  sensitive = true
  default   = "password" # learning only, never hardcode real passwords
}
