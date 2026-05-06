output "app_url" {
  value = " https://${azurerm_linux_web_app.main.default_hostname}"
}

output "key_vault_uri" {
  value = azurerm_key_vault.main.vault_uri
}
