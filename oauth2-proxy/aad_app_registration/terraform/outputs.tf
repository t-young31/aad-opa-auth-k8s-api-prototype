output "client_id" {
  value = azuread_application.api.application_id
}

output "client_secret" {
  value     = azuread_application_password.api.value
  sensitive = true
}
