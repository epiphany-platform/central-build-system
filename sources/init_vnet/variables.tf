variable "name" {
  default = "init-for-cbs"
}

variable "location" {
  default = "northeurope"
}

variable "address_space" {
  default = ["10.250.0.0/16"]
  type    = list
}
variable "address_prefixes" {
  default = ["10.250.1.0/24"]
}

variable "tf_key_path" {
  default = "~/.ssh/id_rsa.pub"
}