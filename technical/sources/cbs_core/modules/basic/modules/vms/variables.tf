variable "name" {
  type = string
}

variable "instances" {
  type    = string
  default = 1
}

variable "rg_name" {
  type = string
}

variable "vnet_id" {
  type = string
}

variable "location" {
  type = string
}

variable "service" {
  type = string
}

variable "use_public_ip" {
  type = bool
}

variable "subnet_id" {
  type = string
}

variable "tf_key_path" {
  type = string
}

variable "vm_size" {
  type    = string
  default = "Standard_DS2_v2"
}

variable "admin_username" {
  type    = string
  default = "operations"
}

variable "image_publisher" {
  type    = string
  default = "Canonical"
}

variable "image_offer" {
  type    = string
  default = "UbuntuServer"
}

variable "image_sku" {
  type    = string
  default = "18.04-LTS"
}

variable "image_version" {
  type    = string
  default = "18.04.202006101"
}
