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
  type = list(string)
}

variable "address_prefixes" {
  type = list(string)
}

variable "rsa_pub_path" {
  type = string
}
