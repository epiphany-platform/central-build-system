resource "tls_private_key" "key" {
  algorithm = "${var.tls_key_algorithm}"
}

resource "tls_self_signed_cert" "cert" {
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
  key_algorithm         = tls_private_key.key.algorithm
  private_key_pem       = tls_private_key.key.private_key_pem
  validity_period_hours = 0
  subject {
    common_name  = "CBS"
    organization = "Epiphany"
  }
  lifecycle { ignore_changes = all }
}
