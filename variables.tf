variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "db_password" {
  type      = string
  sensitive = true
  default   = "password" # learning only, never hardcode real passwords
}

variable "region" {
  type    = string
  default = "ap-southeast-1" # Singapore
}
