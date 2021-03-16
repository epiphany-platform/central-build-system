variable "size" {
  type = number
}

variable "use_public_ip" {
  type = bool
}

variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "address_space" {
  type = string
}

variable "rsa_pub_path" {
  type = string
}

variable "bits_for_subnets" {
  type    = number
  default = 1
}
